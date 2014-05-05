//
//  NewLogInViewController.m
//  test1
//
//  Created by Tim Cheng on 4/13/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "NewLogInViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "ScoreFeedViewController.h"
#import "FBClient.h"
#import "MLApiClient.h"
#import "KeychainItemWrapper.h"

@interface NewLogInViewController () <FBLoginViewDelegate>

@property (weak, nonatomic) ScoreFeedViewController *scoreFeedVC;

@property (strong,nonatomic) IBOutlet UITextField *emailField;
@property (strong,nonatomic) IBOutlet UITextField *passwordField;
@property (strong,nonatomic) KeychainItemWrapper *keychainItem;

- (IBAction)login:(id)sender;

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
    // Do any additional setup after loading the view.
//    FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions:@[@"basic_info", @"email"]];
//    // Align the button in the center horizontally
//    loginView.frame = CGRectOffset(loginView.frame, (self.view.center.x - (loginView.frame.size.width / 2)), (self.view.center.y - (loginView.frame.size.height / 2)));
//    loginView.delegate = self;
//    [self.view addSubview:loginView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"NewLogIn"]) {
        self.scoreFeedVC = ([segue.destinationViewController isKindOfClass:[ScoreFeedViewController class]]) ? segue.destinationViewController : nil;
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
                                     [[MLApiClient client] setLoggedInInfoWithEamil:email
                                                                           password:password
                                                                             userId:[responseJSON[@"id"] integerValue]];
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
    [self performSegueWithIdentifier:@"MainFeed" sender:self];
    
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user
{
    NSLog(@"FB profile fetched ... %@", user);
    [FBClient client].id = user.id;
    [FBClient client].user_name = user.name;
    [self.scoreFeedVC updateInfo];
}


@end
