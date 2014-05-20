//
//  NewLogInViewController.m
//  test1
//
//  Created by Tim Cheng on 4/13/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "NewLogInViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FBClient.h"
#import "MLApiClient.h"
#import "KeychainItemWrapper.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>

@interface NewLogInViewController () <FBLoginViewDelegate>


@property (strong,nonatomic) IBOutlet UITextField *emailField;
@property (strong,nonatomic) IBOutlet UITextField *passwordField;
@property (strong,nonatomic) KeychainItemWrapper *keychainItem;
@property (strong,nonatomic) IBOutlet FBLoginView *fbLoginView;

- (IBAction)login:(id)sender;
- (IBAction)signUp:(id)sender;

@end

@implementation NewLogInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.fbLoginView.readPermissions = @[@"basic_info", @"email"];
    self.fbLoginView.delegate = self;
    
    self.keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"MLLogin" accessGroup:nil];
    NSString *username = [self.keychainItem objectForKey:(__bridge id)kSecAttrAccount];
    if (username && username.length) {
        self.emailField.text = username;
        NSData *pwdData = [self.keychainItem objectForKey:(__bridge id)kSecValueData];
        NSString *password = [NSString stringWithUTF8String:[pwdData bytes]];
        if (password && password.length) {
            self.passwordField.text = password;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

- (void)subscribePush:(NSInteger)userId
{
    NSString *parseChannel = [NSString stringWithFormat:@"user_%d", userId];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:parseChannel forKey:@"channels"];
    [currentInstallation saveInBackground];
}

- (IBAction)login:(id)sender
{
    NSString *email = self.emailField.text;
    NSString *password = self.passwordField.text;
    [[MLApiClient client] loginWithEmail:email
                                password:password
                                 success:^(NSHTTPURLResponse *response, id responseJSON) {
                                     NSLog(@"!!!!!Login succeeded!!!!, %@", responseJSON);
                                     [[MLApiClient client] setLoggedInInfoWithEmail:email
                                                                           password:password
                                                                             userId:[responseJSON[@"id"] integerValue]];
                                     
                                     [self subscribePush:[responseJSON[@"id"] integerValue]];
                                     // save credential to keychain
                                     [self.keychainItem setObject:[self.passwordField.text dataUsingEncoding:NSUTF8StringEncoding]
                                                           forKey:(__bridge id)kSecValueData];
                                     [self.keychainItem setObject:self.emailField.text
                                                           forKey:(__bridge id)kSecAttrAccount];

                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         [self performSegueWithIdentifier:@"MainFeed" sender:self];
                                     });
                                 } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
                                     NSLog(@"!!!!!Login failed");
                                 }];
}

- (IBAction)signUp:(id)sender
{
    [self performSegueWithIdentifier:@"NewSignUp" sender:self];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark FBLoginViewDelegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    NSLog(@"FB logged in ... ");
    //[self performSegueWithIdentifier:@"MainFeed" sender:self];
    
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user
{
    NSString *email = user[@"email"];
    NSString *accessToken = [[[FBSession activeSession] accessTokenData] accessToken];
    NSString *loginEmail = [NSString stringWithFormat:@"%@@fb", email];
    
    NSLog(@"FB profile fetched ... %@, %@, %@", user, loginEmail, accessToken);
    
    [[MLApiClient client] loginWithFB:email
                          accessToken:accessToken
                            firstName:user[@"first_name"]
                             lastName:user[@"last_name"]
                                 fbId:user[@"id"]
                              success:^(NSHTTPURLResponse *response, id responseJSON) {
                                  NSLog(@"!!!!!FB Login succeeded!!!!, %@", responseJSON);
                                  [[MLApiClient client] setLoggedInInfoWithEmail:loginEmail
                                                                        password:accessToken
                                                                          userId:[responseJSON[@"id"] integerValue]];
                                  [self subscribePush:[responseJSON[@"id"] integerValue]];
                                  if (response.statusCode == 201) {
                                      // just created new user, need to upload photo
                                      NSLog(@"new FB user created!!!");
                                  }
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [self performSegueWithIdentifier:@"MainFeed" sender:self];
                                  });
                              } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
                                  NSLog(@"!!!!!FB Login failed!!!!, %@", responseJSON);
                              }];
}


@end
