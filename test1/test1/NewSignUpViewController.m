//
//  NewSignUpViewController.m
//  test1
//
//  Created by Tim Cheng on 5/14/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "NewSignUpViewController.h"
#import "MLApiClient.h"

@interface NewSignUpViewController ()

@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UITextField *firstNameField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameField;


- (IBAction)nextStep:(id)sender;
- (IBAction)addChild:(id)sender;

@end

@implementation NewSignUpViewController


- (void)viewDidLoad
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

#pragma mark - IBAction
- (IBAction)nextStep:(id)sender
{
    // TODO: email/password/validation
    
    [[MLApiClient client] createUser:self.emailField.text
                            password:self.passwordField.text
                           firstName:self.firstNameField.text
                            lastName:self.lastNameField.text
                             success:^(NSHTTPURLResponse *response, id responseJSON) {
                                 NSLog(@"user account created!");
                                 [[MLApiClient client] setLoggedInInfoWithEmail:self.emailField.text
                                                                       password:self.passwordField.text
                                                                         userId:[responseJSON[@"id"] integerValue]];

                                 // TODO: save cred to keychain
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [self performSegueWithIdentifier:@"GoMain" sender:self];
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

@end
