//
//  ViewController.m
//  test1
//
//  Created by Tim Cheng on 3/22/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "StatusUpdateViewController.h"
#import <Firebase/Firebase.h>
#import "NSStrinAdditions.h"
#import <FacebookSDK/FacebookSDK.h>
#import "NSDate+TimeAgo.h"


@interface StatusUpdateViewController () <UITextFieldDelegate,
                              UIImagePickerControllerDelegate,
                              UINavigationControllerDelegate,
                              UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITextField *statusField;
@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet UITableView *feedView;

@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) Firebase *firebase;
@property (strong, nonatomic) NSMutableArray *feedArray;
@property (strong, nonatomic) NSDateFormatter *myFormatter;
@property (strong, nonatomic) NSString *fbID;

- (IBAction) didTapButton:(id)sender;
- (IBAction) didTapUploadButton:(id)sender;

@end

@implementation StatusUpdateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.myFormatter = [[NSDateFormatter alloc] init];
    [self.myFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];

    self.feedArray = [[NSMutableArray alloc] initWithCapacity:100];
    self.feedView.dataSource = self;
    self.statusField.delegate = self;

	
    self.firebase = [[Firebase alloc] initWithUrl:@"https://monitortest.firebaseIO.com/"];
    [self.firebase observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSMutableArray* insertingRows = [NSMutableArray array];
        int inCnt = [snapshot.value count];
        int feedCnt = [self.feedArray count];
        if (inCnt > feedCnt) {
            for (int i=feedCnt; i<inCnt; i++) {
                [self.feedArray addObject:snapshot.value[i]];
                [insertingRows addObject:[NSIndexPath indexPathForRow:i-feedCnt inSection:0]];
            }
            [self.feedView beginUpdates];
            [self.feedView insertRowsAtIndexPaths:insertingRows withRowAnimation:UITableViewRowAnimationAutomatic];;
            [self.feedView endUpdates];
        } else {
            NSLog(@"inconsistency!");
        }
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUserInfo:(FBLoginView *)loginView
                  user:(id<FBGraphUser>)user
{
    self.profilePictureView.profileID = user.id;
    self.fbID = user.id;
    self.nameLabel.text = user.name;
}


#pragma mark UITextFieldDelgate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [self.firebase observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        long dataLength = snapshot.childrenCount;
        NSString *indexPath = [NSString stringWithFormat: @"%ld", dataLength];
        Firebase* newStatusRef = [self.firebase childByAppendingPath:indexPath];
        
        NSMutableDictionary *dict =[[NSMutableDictionary alloc]
                                    initWithDictionary:@{
                                                         @"user":self.nameLabel.text,
                                                         @"status":textField.text,
                                                         @"time":[self.myFormatter stringFromDate:[NSDate date]]
                                                         }];
        
        if (self.fbID) {
            [dict addEntriesFromDictionary:@{@"fb_id" : self.fbID}];
        }
        [newStatusRef setValue:dict];
        textField.text = @"";
    }];
    
    return NO;
}

#pragma mark UIImagePickerControllerDelegate

- (void) imagePickerController:(UIImagePickerController *)picker
         didFinishPickingImage:(UIImage *)image
                   editingInfo:(NSDictionary *)editingInfo
{
    self.userImageView.image = image;
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark IBActions

- (IBAction) didTapButton:(id)sender
{
    UIImagePickerController *pickerController = [[UIImagePickerController alloc]
                                                 init];
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:NULL];
}

- (IBAction) didTapUploadButton:(id)sender
{
//    NSData *imageData = UIImageJPEGRepresentation(self.userImageView.image, 0.9);
//    NSString *imageString = [NSString base64StringFromData:imageData length:[imageData length]];
//    
//    [self.firebase observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//        long dataLength = snapshot.childrenCount;
//        NSString *indexPath = [NSString stringWithFormat: @"%ld", dataLength];
//        Firebase* newImageRef = [self.firebase childByAppendingPath:indexPath];
//        [newImageRef setValue:@{@"myImage": imageString, @"someObjectId": @"null"}];
//    }];
}

#pragma mark UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.feedArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FeedCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    NSDictionary *feed = self.feedArray[[self.feedArray count] - 1 - indexPath.row];
    
    FBProfilePictureView *imgView = (FBProfilePictureView*)[cell.contentView viewWithTag:10];
    [imgView.layer setCornerRadius:10.0f];
    
    if (feed[@"fb_id"]) {
        imgView.profileID = feed[@"fb_id"];
    } else {
        // TOODO:
        if (self.fbID) {
            imgView.profileID = self.fbID;
        }
    }
    
    UILabel *name = (UILabel *)[cell.contentView viewWithTag:11];
    name.text = feed[@"user"];
    
    NSString *timeString = feed[@"time"];
    NSString *displayTime = @"long ago";
    if (timeString) {
        NSDate *time = [self.myFormatter dateFromString:feed[@"time"]];
        displayTime = [time timeAgo];
    }
    UILabel *time = (UILabel *)[cell.contentView viewWithTag:12];
    time.text = displayTime;

    UITextView *status = (UITextView *)[cell.contentView viewWithTag:13];
    status.text = feed[@"status"];
    
    return cell;
}

@end