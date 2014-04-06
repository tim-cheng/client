//
//  LoginUIViewController.m
//  test1
//
//  Created by Tim Cheng on 3/24/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "LoginUIViewController.h"
#import "SignUpViewController.h"
#import "StatusUpdateViewController.h"
#import "EmojiPickerViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "DBClient.h"
#import "KeychainItemWrapper.h"

@interface LoginUIViewController() <FBLoginViewDelegate>

@property (strong,nonatomic) StatusUpdateViewController *statusVC;
@property (strong,nonatomic) SignUpViewController *signupVC;
@property (strong,nonatomic) EmojiPickerViewController *emojiVC;

@property (strong,nonatomic) IBOutlet UITextField *emailField;
@property (strong,nonatomic) IBOutlet UITextField *passwordField;

@property (strong,nonatomic) KeychainItemWrapper *keychainItem;

- (IBAction)login:(id)sender;
- (IBAction)signup:(id)sender;

@end

@implementation LoginUIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"PLLogin" accessGroup:nil];
    
    NSString *username = [self.keychainItem objectForKey:(__bridge id)kSecAttrAccount];
    if (username && username.length) {
        self.emailField.text = username;
        NSData *pwdData = [self.keychainItem objectForKey:(__bridge id)kSecValueData];
        NSString *password = [NSString stringWithUTF8String:[pwdData bytes]];
        if (password && password.length) {
            self.passwordField.text = password;
            //[self login:self];
        }
    }
}

- (IBAction)login:(id)sender
{
    [[DBClient client].firebaseAuth loginWithEmail:self.emailField.text andPassword:self.passwordField.text
                               withCompletionBlock:^(NSError* error, FAUser* user) {
                                   if (error != nil) {
                                       // There was an error logging in to this account
                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed"
                                                                                       message:[error description]
                                                                                      delegate:nil
                                                                             cancelButtonTitle:@"OK"
                                                                             otherButtonTitles:nil];
                                       [alert show];
                                   } else {
                                       [DBClient client].loggedInUserId = user.userId;
                                       [self.keychainItem setObject:[self.passwordField.text dataUsingEncoding:NSUTF8StringEncoding]
                                                             forKey:(__bridge id)kSecValueData];
                                       [self.keychainItem setObject:self.emailField.text
                                                             forKey:(__bridge id)kSecAttrAccount];
                                       //[self performSegueWithIdentifier:@"LoggedIn" sender:self];
                                       [self performSegueWithIdentifier:@"PickEmoji" sender:self];
                                   }
                               }];
}

- (IBAction)signup:(id)sender
{
    FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions:@[@"basic_info", @"email"]];
    
    // Align the button in the center horizontally
    loginView.frame = CGRectOffset(loginView.frame, (self.view.center.x - (loginView.frame.size.width / 2)), (self.view.center.y - (loginView.frame.size.height / 2)));
    
    loginView.delegate = self;
    
    //[self.view addSubview:loginView];
    [self performSegueWithIdentifier:@"SignUp" sender:self];
}

#pragma mark FBLoginViewDelegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    NSLog(@"FB logged in ... ");
    
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user
{
    NSLog(@"FB profile fetched ... %@", user);
    if (self.statusVC) {
        //[self.statusVC updateUserInfo:loginView user:user];
    }
    if (self.signupVC) {
        [self.signupVC updateUserInfo:loginView user:user];
    }
    if (self.emojiVC) {
        self.emojiVC.fbID = user.id;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"LoggedIn"]) {
        self.statusVC = ([segue.destinationViewController isKindOfClass:[StatusUpdateViewController class]]) ? segue.destinationViewController : nil;
    } else if ([segue.identifier isEqualToString:@"SignUp"]) {
        self.signupVC = ([segue.destinationViewController isKindOfClass:[SignUpViewController class]]) ? segue.destinationViewController : nil;
    } else if ([segue.identifier isEqualToString:@"PickEmoji"]) {
        //
        self.emojiVC = ([segue.destinationViewController isKindOfClass:[EmojiPickerViewController class]]) ? segue.destinationViewController : nil;
    }
}

@end
