//
//  EmailLoginViewController.m
//  test1
//
//  Created by Tim Cheng on 5/25/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "EmailLoginViewController.h"
#import "MLApiClient.h"
#import "KeychainItemWrapper.h"
#import <Parse/Parse.h>


@interface EmailLoginViewController ()

@property (strong,nonatomic) IBOutlet UITextField *emailField;
@property (strong,nonatomic) IBOutlet UITextField *passwordField;
@property (strong,nonatomic) KeychainItemWrapper *keychainItem;

- (IBAction)login:(id)sender;

@end


@implementation EmailLoginViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];


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

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *autoLogin = [defaults objectForKey:@"autoLogin"];
    if ([autoLogin isEqualToString:@"email"]) {
        [self login:self];
    }
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

                                     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                     [defaults setObject:@"email" forKey:@"autoLogin"];
                                     [defaults synchronize];
                                     
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         [self performSegueWithIdentifier:@"EmailGoMain" sender:self];
                                         [self.navigationController popViewControllerAnimated:NO];
                                     });
                                 } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
                                     NSLog(@"!!!!!Login failed");
                                 }];
}

- (void)subscribePush:(NSInteger)userId
{
    NSString *parseChannel = [NSString stringWithFormat:@"user_%d", userId];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:parseChannel forKey:@"channels"];
    [currentInstallation saveInBackground];
}



@end
