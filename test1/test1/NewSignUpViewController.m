//
//  NewSignUpViewController.m
//  test1
//
//  Created by Tim Cheng on 5/14/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "NewSignUpViewController.h"
#import "MLApiClient.h"

@interface NewSignUpViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UITextField *firstNameField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameField;
@property (strong, nonatomic) IBOutlet UITextField *locationField;

@property (strong, nonatomic) IBOutlet UIButton *profButton;

@property (assign, nonatomic) BOOL hasProfPicture;

- (IBAction)nextStep:(id)sender;
- (IBAction)addChild:(id)sender;

-(IBAction)addPhoto:(id)sender;

@end

@implementation NewSignUpViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.navigationController setNavigationBarHidden:NO];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    UIImageView *img = self.profButton.imageView;
    img.layer.borderWidth = 1.0f;
    img.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    img.layer.cornerRadius = 36;
    img.clipsToBounds = YES;
}


- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

- (IBAction)addPhoto:(id)sender
{
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Take Photo", @"Choose Exising", nil];
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}


#pragma mark - IBAction
- (IBAction)nextStep:(id)sender
{
    // TODO: email/password/validation
    // TOOD: location / zip
    if (self.emailField.text.length == 0 ||
        self.passwordField.text.length == 0 ||
        self.firstNameField.text.length == 0 ||
        self.lastNameField.text.length == 0 ||
        self.locationField.text.length == 0) {
        UIAlertView *warn = [[UIAlertView alloc] initWithTitle:@"Create Accout Failed"
                                                       message:@"All fields are required"
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
        [warn show];
        return;
    }
    [[MLApiClient client] createUser:self.emailField.text
                            password:self.passwordField.text
                           firstName:self.firstNameField.text
                            lastName:self.lastNameField.text
                            location:self.locationField.text
                                 zip:@""
                             success:^(NSHTTPURLResponse *response, id responseJSON) {
                                 NSLog(@"user account created!");
                                 [[MLApiClient client] setLoggedInInfoWithEmail:self.emailField.text
                                                                       password:self.passwordField.text
                                                                         userId:[responseJSON[@"id"] integerValue]];
                                 
                                 if (self.hasProfPicture) {
                                     [[MLApiClient client] sendUserPictureId:kApiClientUserSelf
                                                                       image:self.profButton.imageView.image
                                                                     success:^(NSHTTPURLResponse *response, id responseJSON) {
                                                                         NSLog(@"user picture uploaded: %@", responseJSON);
                                                                     } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
                                                                         NSLog(@"user picture upload failed");
                                                                     }];
                                 }
                                 // TODO: save cred to keychain
//                                 [self dismissViewControllerAnimated:NO completion:^{
//                                     [self performSegueWithIdentifier:@"GoMain" sender:self];
//                                 }];
                                 
                                 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                 [defaults setObject:@(YES) forKey:@"firstSignup"];
                                 [defaults synchronize];

                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [self performSegueWithIdentifier:@"GoMain" sender:self];
                                     [self.navigationController popViewControllerAnimated:NO];
                                 });
                             } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
                                 NSLog(@"create account failed...");
                                 // TODO: error message should come from backend
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     UIAlertView *warn = [[UIAlertView alloc] initWithTitle:@"Create Accout Failed"
                                                                                    message:@"Failed to create user, please double check your email/password"
                                                                                   delegate:self
                                                                          cancelButtonTitle:@"OK"
                                                                          otherButtonTitles:nil];
                                     [warn show];
                                 });
                             }];
}

- (IBAction)addChild:(id)sender
{
    [self performSegueWithIdentifier:@"AddChild" sender:self];
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
    
    self.profButton.imageView.image = newImage;
    self.hasProfPicture = YES;
}




@end
