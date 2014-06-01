//
//  UserProfileViewController.m
//  test1
//
//  Created by Tim Cheng on 5/18/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "UserProfileViewController.h"
#import "MainFeedViewController.h"
#import "MLApiClient.h"
#import "MLUserInfo.h"
#import "AddChildViewController.h"
#import "MLHelpers.h"

@interface UserProfileViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *profImgView;

@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *locationField;
@property (strong, nonatomic) IBOutlet UILabel *connectionLabel;
@property (strong, nonatomic) IBOutlet UITextView *bioView;

@property (strong, nonatomic) IBOutlet UITableView *kidsView;

@property (strong, nonatomic) NSMutableArray *kidsArray;

@property (assign, nonatomic) NSInteger editKidRow;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButtonItem;

@property (strong, nonatomic) IBOutlet UIButton *addKidButton;

@property (assign, nonatomic) BOOL isSelf;
@property (assign, nonatomic) BOOL picChanged;


-(IBAction)addKid:(id)sender;

@end

@implementation UserProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
//                                   initWithTarget:self
//                                   action:@selector(dismissKeyboard)];
//    
//    [self.view addGestureRecognizer:tap];

    self.kidsArray = [[NSMutableArray alloc] init];
    
    if (self.userId == 0) {
        self.userId = [MLApiClient client].userId;
        self.isSelf = YES;
    } else {
        self.isSelf = NO;
    }
    
    self.addKidButton.hidden = !self.isSelf;
    
    self.profImgView.image = [[MLUserInfo instance] userPicture:self.userId];
    self.profImgView.layer.borderWidth = 1.0f;
    self.profImgView.layer.borderColor = [MLColor CGColor];
    self.profImgView.layer.cornerRadius = 32;
    self.profImgView.clipsToBounds = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self
                                         action:@selector(changePhoto:)];
    [singleTap setNumberOfTapsRequired:1];
    self.profImgView.userInteractionEnabled = YES;
    [self.profImgView addGestureRecognizer:singleTap];

    
    [[MLUserInfo instance] userInfoFromId:self.userId success:^(id responseJSON) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"get user info: %@", responseJSON);
            NSDictionary *userInfo = (NSDictionary *)responseJSON;
            self.nameField.text = userInfo[@"full_name"];
            self.connectionLabel.text = [NSString stringWithFormat:@"%d Connections   %d Parents in 2° network", [userInfo[@"num_degree1"] integerValue], [userInfo[@"num_degree2"] integerValue]];
            self.bioView.text = userInfo[@"interests"];
            self.locationField.text = userInfo[@"location"];
        });
    }];
    
    self.kidsView.dataSource = self;
    self.kidsView.delegate = self;
    self.nameField.delegate = self;
    self.locationField.delegate = self;
    
    self.bioView.delegate = self;

}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadKids];
}

-(void)loadKids
{
    [[MLApiClient client] kidsForId:self.userId success:^(NSHTTPURLResponse *response, id responseJSON) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self clearKids];
            NSLog(@"got kids %@", responseJSON);
            [self.kidsArray addObjectsFromArray:responseJSON];
            [self.kidsView beginUpdates];
            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
            for (int i=0; i<[self.kidsArray count]; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            [self.kidsView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [self.kidsView endUpdates];

        });

    } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self clearKids];
        });
    }];
}

-(IBAction)addKid:(id)sender
{
    self.editKidRow = -1;
    [self performSegueWithIdentifier:@"AddKid" sender:self];
}

- (void)changePhoto:(UITapGestureRecognizer *)gest
{
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Take Photo", @"Choose Exising", nil];
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)clearKids
{
    if ([self.kidsArray count] > 0) {
        [self.kidsView beginUpdates];
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        for (int i=0; i<[self.kidsArray count]; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        [self.kidsView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [self.kidsArray removeAllObjects];
        [indexPaths removeAllObjects];
        [self.kidsView endUpdates];
    }
}

-(void)saveProfile
{
    NSArray *names = [self.nameField.text componentsSeparatedByString:@" "];
    if ([names count] < 2) {
        NSLog(@"malformatted name... ");
        return;
    }
    
    [[MLApiClient client] updateUserInfoFromId:kApiClientUserSelf firstName:names[0]
                                      lastName:names[1]
                                      location:self.locationField.text
                                     interests:self.bioView.text success:^(NSHTTPURLResponse *response, id responseJSON) {
                                         NSLog(@"user info updated...");
                                         [[MLUserInfo instance] invalidateUserInfoFromId:[MLApiClient client].userId];
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             UIAlertView *warn = [[UIAlertView alloc] initWithTitle:nil
                                                                                            message:@"User profile updated"
                                                                                           delegate:self
                                                                                  cancelButtonTitle:@"OK"
                                                                                  otherButtonTitles:nil];
                                             [warn show];
                                             self.saveButtonItem.enabled = NO;
                                             [self dismissKeyboard];
                                         });

                                     } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
                                         NSLog(@"user info update failed...");
                                     }];
    if (self.picChanged) {
        [[MLApiClient client] sendUserPictureId:kApiClientUserSelf
                                          image:self.profImgView.image
                                        success:^(NSHTTPURLResponse *response, id responseJSON) {
                                            NSLog(@"user image updated!");
                                        } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
                                            NSLog(@"user image update failed!");
                                        }];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *pickerController = [[UIImagePickerController alloc]
                                                 init];
    pickerController.delegate = self;
    pickerController.sourceType = (buttonIndex == 0) ?
    UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:pickerController animated:YES completion:NULL];
}

#pragma mark - UIImagePickerControllerDelegate

- (void) imagePickerController:(UIImagePickerController *)picker
         didFinishPickingImage:(UIImage *)image
                   editingInfo:(NSDictionary *)editingInfo
{
    // crop
    CGRect newRect;
    if (image.size.width < image.size.height) {
        float offset = (image.size.height - image.size.width) / 2;
        // note, CGImage is not rotated
        newRect = CGRectMake(offset, 0, image.size.width, image.size.width);
    } else {
        float offset = (image.size.width - image.size.height) / 2;
        newRect = CGRectMake(offset, 0, image.size.height, image.size.height);
    }
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], newRect);
    UIImage *cropImage = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    
    // scale
    CGSize newSize = CGSizeMake(128.0, 128.0);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [cropImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    [self dismissModalViewControllerAnimated:YES];
    UIGraphicsEndImageContext();
    
    self.profImgView.image = newImage;
    self.picChanged = YES;
    self.saveButtonItem.enabled = YES;
}


#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.kidsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ChildCell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *kidInfo = self.kidsArray[indexPath.row];
    UIImageView *picView = (UIImageView *)[cell.contentView viewWithTag:10];
    if ([kidInfo[@"boy"] boolValue]) {
        picView.image = [UIImage imageNamed:@"boy_color_64.png"];
    } else {
        picView.image = [UIImage imageNamed:@"girl_color_64.png"];
    }

    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:11];
    nameLabel.text = kidInfo[@"name"];

    UILabel *ageLabel = (UILabel *)[cell.contentView viewWithTag:12];
    ageLabel.text = [NSString stringWithFormat:@"%@ years old", kidInfo[@"age"]];

    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSelf) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        self.editKidRow = indexPath.row;
        [self performSegueWithIdentifier:@"AddKid" sender:self];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddKid"]) {
        AddChildViewController *childVC = segue.destinationViewController;
        if (self.editKidRow >= 0) {
            childVC.kidId = [self.kidsArray[self.editKidRow][@"id"] integerValue];
            childVC.kidName = self.kidsArray[self.editKidRow][@"name"];
            childVC.kidBirthday = @"2010-10-10";
            childVC.kidIsBoy = [self.kidsArray[self.editKidRow][@"boy"] boolValue];
        } else {
            childVC.kidId = -1;
        }
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSLog(@"enable save");
    self.saveButtonItem.enabled = YES;
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.isSelf) {
        self.saveButtonItem.enabled = YES;
    }
    return self.isSelf;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (self.isSelf) {
        self.saveButtonItem.enabled = YES;
    }
    return self.isSelf;
}

@end
