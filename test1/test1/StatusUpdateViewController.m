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
#import "ProfileViewController.h"
#import "DBClient.h"
#import "InfiniteScrollPicker.h"
#import "SWTableViewCell.h"
#import "WXApi.h"

@interface FeedTableViewCell : SWTableViewCell

@end

@implementation FeedTableViewCell 

@end


@interface StatusUpdateViewController () <UITextFieldDelegate,
                              UIImagePickerControllerDelegate,
                              UINavigationControllerDelegate,
                              UITableViewDataSource,
                              UIScrollViewDelegate,
                              SWTableViewCellDelegate>

@property (strong, nonatomic) IBOutlet UITextField *statusField;
//@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet UITableView *feedView;

@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) Firebase *postRef;
@property (strong, nonatomic) Firebase *profileRef;
@property (strong, nonatomic) NSArray *friends;
@property (strong, nonatomic) NSMutableArray *feedArray;
@property (strong, nonatomic) NSDateFormatter *myFormatter;
@property (strong, nonatomic) NSString *fbID;

@property (strong, nonatomic) NSMutableDictionary *emoticons;
@property (strong, nonatomic) NSMutableDictionary *emoticonChars;
@property (strong, nonatomic) NSString *currentEmotion;


@property (strong, nonatomic) ProfileViewController *profileVC;

//- (IBAction) didTapButton:(id)sender;
//- (IBAction) didTapUploadButton:(id)sender;
- (IBAction) logOut:(id)sender;

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

    // customize profilePicture
    self.profilePictureView.layer.cornerRadius = 10.0f;
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(tapSelfProfile:)];
    [self.profilePictureView addGestureRecognizer:singleFingerTap];
    
    NSString *baseLoc = [DBClient urlForLoggedInUser];

    Firebase *profileRef = [[Firebase alloc] initWithUrl:[baseLoc stringByAppendingString:@"/profile"]];
    [profileRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"profile: %@", snapshot.value);
        if ([snapshot.value isKindOfClass:[NSDictionary class]]) {
            self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", snapshot.value[@"first_name"], snapshot.value[@"last_name"]];
            self.fbID = snapshot.value[@"fb_id"];
            self.profilePictureView.profileID = self.fbID;
        }
    }];

    Firebase *friendRef = [[Firebase alloc] initWithUrl:[baseLoc stringByAppendingString:@"/friend"]];
    [friendRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if ([snapshot.value isKindOfClass:[NSDictionary class]]) {
            self.friends = [snapshot.value allKeys];
            NSLog(@"friends :%@", self.friends);
        }
        
    }];
    
    self.postRef = [[Firebase alloc] initWithUrl:[baseLoc stringByAppendingString:@"/post"]];
    [self.postRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        //NSLog(@"post: %@", snapshot.value);
        if ([snapshot.value isKindOfClass:[NSArray class]]) {
            int inCnt = (int)[snapshot.value count];
            int feedCnt = (int)[self.feedArray count];
            NSArray *indexPaths = @[[NSIndexPath indexPathForRow:0 inSection:0]];
            if (inCnt > feedCnt) {
                for (int i=feedCnt; i<inCnt; i++) {
                    [self.feedArray addObject:snapshot.value[i]];
                    //[self.feedView beginUpdates];
                    [self.feedView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                    //[self.feedView endUpdates];
                }
            } else {
                NSLog(@"inconsistency!");
            }
        }
    }];
    
    self.emoticons = [[NSMutableDictionary alloc] init];
    self.emoticonChars = [[NSMutableDictionary alloc] init];
    UIImage *img;
    
    img = [UIImage imageNamed:@"emoticon_happy.png"];
    img.accessibilityIdentifier = @"happy";
    self.emoticons[@"happy"] = img;
    self.emoticonChars[@"happy"] = @"\U0001F604";

    img = [UIImage imageNamed:@"emoticon_straight_face.png"];
    img.accessibilityIdentifier = @"flat";
    self.emoticons[@"flat"] = img;
    self.emoticonChars[@"flat"] = @"\U0001F614";

    img = [UIImage imageNamed:@"emoticon_sad.png"];
    img.accessibilityIdentifier = @"sad";
    self.emoticons[@"sad"] = img;
    self.emoticonChars[@"sad"] = @"\U0001F622";

    img = [UIImage imageNamed:@"emoticon_nervous.png"];
    img.accessibilityIdentifier = @"nervous";
    self.emoticons[@"nervous"] = img;
    self.emoticonChars[@"nervous"] = @"\U0001F616";

    img = [UIImage imageNamed:@"emoticon_oh_no.png"];
    img.accessibilityIdentifier = @"oh_no";
    self.emoticons[@"oh_no"] = img;
    self.emoticonChars[@"oh_no"] = @"\U0001F635";

    img = [UIImage imageNamed:@"emoticon_lol.png"];
    img.accessibilityIdentifier = @"lol";
    self.emoticons[@"lol"] = img;
    self.emoticonChars[@"lol"] = @"\U0001F606";

    img = [UIImage imageNamed:@"emoticon_smile.png"];
    img.accessibilityIdentifier = @"smile";
    self.emoticons[@"smile"] = img;
    self.emoticonChars[@"smile"] = @"\U0001F60F";

    
    InfiniteScrollPicker *isp = [[InfiniteScrollPicker alloc] initWithFrame:CGRectMake(10, 80, 300, 100)];
    [isp setItemSize:CGSizeMake(50, 50)];
    [isp setImageAry:[self.emoticons allValues]];
    [self.view addSubview:isp];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tapSelfProfile:(UITapGestureRecognizer *)recognizer
{
    [self performSegueWithIdentifier:@"ShowSelfProfile" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowSelfProfile"]) {
        self.profileVC = ([segue.destinationViewController isKindOfClass:[ProfileViewController class]]) ? segue.destinationViewController : nil;
        NSLog(@"ready to segue");
        self.profileVC.fbID = self.fbID;
        self.profileVC.fbName = self.nameLabel.text;
        self.profileVC.friends = [self.friends mutableCopy];
    }
}



- (void) postToSnapshot:(FDataSnapshot *)snapshot fromDict:(NSDictionary *)dict forRef:(Firebase *)ref
{
    long dataLength = snapshot.childrenCount;
    NSString *indexPath = [NSString stringWithFormat: @"%ld", dataLength];
    Firebase* newStatusRef = [ref childByAppendingPath:indexPath];
    [newStatusRef setValue:dict];
}

#pragma mark UITextFieldDelgate


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    
    NSMutableDictionary *dict =[[NSMutableDictionary alloc]
                                initWithDictionary:@{
                                                     @"user":self.nameLabel.text,
                                                     @"status":textField.text,
                                                     @"time":[self.myFormatter stringFromDate:[NSDate date]]
                                                     }];
    
    if (self.fbID) {
        dict[@"fb_id"] = self.fbID;
    }
    
    if (self.currentEmotion) {
        dict[@"mood"] = self.currentEmotion;
    }
    
    textField.text = @"";
    
    

    [self.postRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        [self postToSnapshot:snapshot fromDict:dict forRef:self.postRef];
    }];
    
    for (NSString *fid in self.friends) {
        NSString *friendBaseLoc = [DBClient urlForUserId:fid];
        Firebase *friendPostRef = [[Firebase alloc] initWithUrl:[friendBaseLoc stringByAppendingString:@"/post"]];
        [friendPostRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            [self postToSnapshot:snapshot fromDict:dict forRef:friendPostRef];
        }];
    }

    return NO;
}

#pragma mark UIImagePickerControllerDelegate

//- (void) imagePickerController:(UIImagePickerController *)picker
//         didFinishPickingImage:(UIImage *)image
//                   editingInfo:(NSDictionary *)editingInfo
//{
//    self.userImageView.image = image;
//    [self dismissModalViewControllerAnimated:YES];
//}

#pragma mark IBActions

//- (IBAction) didTapButton:(id)sender
//{
//    UIImagePickerController *pickerController = [[UIImagePickerController alloc]
//                                                 init];
//    pickerController.delegate = self;
//    [self presentViewController:pickerController animated:YES completion:NULL];
//}

//- (IBAction) didTapUploadButton:(id)sender
//{
//    NSData *imageData = UIImageJPEGRepresentation(self.userImageView.image, 0.9);
//    NSString *imageString = [NSString base64StringFromData:imageData length:[imageData length]];
//    
//    [self.firebase observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//        long dataLength = snapshot.childrenCount;
//        NSString *indexPath = [NSString stringWithFormat: @"%ld", dataLength];
//        Firebase* newImageRef = [self.firebase childByAppendingPath:indexPath];
//        [newImageRef setValue:@{@"myImage": imageString, @"someObjectId": @"null"}];
//    }];
//}

- (IBAction) logOut:(id)sender
{
    [self performSegueWithIdentifier:@"LogOut" sender:self];
}

#pragma mark UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.feedArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FeedCell";
    
    FeedTableViewCell *cell = (FeedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FeedTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }

    __weak FeedTableViewCell *weakCell = cell;
    [cell setAppearanceWithBlock:^{
        weakCell.containingTableView = tableView;
        
        NSMutableArray *leftUtilityButtons = [NSMutableArray new];
        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
        
//        [leftUtilityButtons sw_addUtilityButtonWithColor:
//         [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0]
//                                                    icon:[UIImage imageNamed:@"check.png"]];
//        [leftUtilityButtons sw_addUtilityButtonWithColor:
//         [UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:1.0]
//                                                    icon:[UIImage imageNamed:@"clock.png"]];
//        [leftUtilityButtons sw_addUtilityButtonWithColor:
//         [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0]
//                                                    icon:[UIImage imageNamed:@"cross.png"]];
//        [leftUtilityButtons sw_addUtilityButtonWithColor:
//         [UIColor colorWithRed:0.55f green:0.27f blue:0.07f alpha:1.0]
//                                                    icon:[UIImage imageNamed:@"list.png"]];
        
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:0.23046875f green:0.34765625f blue:0.59765625f alpha:1.0]
                                                    title:@"Facebook"];
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:0.231f green:0.8f blue:0.388 alpha:1.0f]
                                                    title:@"WeChat"];
        
        weakCell.leftUtilityButtons = leftUtilityButtons;
        weakCell.rightUtilityButtons = rightUtilityButtons;
        
        weakCell.delegate = self;
    } force:NO];
    
    
    NSDictionary *feed = self.feedArray[[self.feedArray count] - 1 - indexPath.row];
    
    FBProfilePictureView *imgView = (FBProfilePictureView*)[cell.contentView viewWithTag:10];
    imgView.layer.cornerRadius = 10.0f;
    
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
    
    UIImageView *icon = (UIImageView *)[cell.contentView viewWithTag:14];
    if (feed[@"mood"]) {
        icon.image = self.emoticons[feed[@"mood"]];
    } else {
        icon.image = nil;
        //icon.image = self.emoticons[@"straight"];
    }
    
    return cell;
}

- (void)infiniteScrollPicker:(InfiniteScrollPicker *)infiniteScrollPicker didSelectAtImage:(UIImage *)buttonIndex
{
    NSLog(@"snapped %@!", buttonIndex.accessibilityIdentifier);
    self.currentEmotion = buttonIndex.accessibilityIdentifier;
}

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
//    switch (index) {
//        case 0:
//            NSLog(@"check button was pressed");
//            break;
//        case 1:
//            NSLog(@"clock button was pressed");
//            break;
//        case 2:
//            NSLog(@"cross button was pressed");
//            break;
//        case 3:
//            NSLog(@"list button was pressed");
//        default:
//            break;
//    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [self.feedView indexPathForCell:cell];
//    NSLog(@"count = %d, row = %d", [self.feedArray count], indexPath.row);
    NSDictionary *feed = self.feedArray[[self.feedArray count] - 1 - indexPath.row];
    NSString *postTxt = feed[@"status"];
    
    UIImage *img = nil;
    if (feed[@"mood"] && self.emoticons[feed[@"mood"]]) {
        img = self.emoticons[feed[@"mood"]];
        postTxt = [postTxt stringByAppendingString:self.emoticonChars[feed[@"mood"]]];
    }
    NSLog(@"my status = %@", postTxt);
    
    switch (index) {
        case 0:
        {
            NSLog(@"Share to FB");
            NSArray *permissionsNeeded = @[@"publish_actions"];
            [FBSession openActiveSessionWithPublishPermissions:permissionsNeeded
                                               defaultAudience:FBSessionDefaultAudienceOnlyMe
                                                  allowLoginUI:YES
                                             completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                 if (!error) {
                     NSLog(@"got publish permission");
                     [FBDialogs presentOSIntegratedShareDialogModallyFrom:self
                                                              initialText:postTxt
                                                                    image:img
                                                                      url:nil
                                                                  handler:^(FBOSIntegratedShareDialogResult result, NSError *error) {
                         NSLog(@"dialog dismissed: %d, %@", result, error);
                     }];

//                     [FBDialogs presentShareDialogWithLink:nil name:postTxt handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
//                     }];
                     
                 } else {
                     NSLog(@"got error: %@", error);
                 }
             }];
            
            break;
        }
        case 1:
        {
            NSLog(@"Share to WeChat");
            // share to WeChat
//            WXMediaMessage *message = [WXMediaMessage message];
//            message.title = @"Some Title";
//            message.description = status;
//            [message setThumbImage:img];
            
            SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
//            req.bText = NO;
//            req.message = message;
            req.bText = YES;
            req.text = postTxt;
            req.scene = WXSceneTimeline;
            [WXApi sendReq:req];

            break;
        }
        default:
            break;
    }
}
@end