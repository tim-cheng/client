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
#import <FacebookSDK/FacebookSDK.h>
#import "MLApiClient.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "MLHelpers.h"

@interface NewLogInViewController ()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)signUp:(id)sender;
- (IBAction)emailLogin:(id)sender;
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
    [self.navigationController setNavigationBarHidden:YES];
//    UIImageView *splash = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bird.jpg"]];
//    [self.view addSubview:splash];
//    [self.view sendSubviewToBack:splash];

    self.view.backgroundColor = MLColor;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}


- (IBAction)signUp:(id)sender
{
    [self performSegueWithIdentifier:@"NewSignUp" sender:self];
}

- (IBAction)emailLogin:(id)sender
{
    [self performSegueWithIdentifier:@"EmailLogin" sender:self];
}

- (IBAction)fbLogin:(id)sender
{
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        
        // If the session state is not any of the two "open" states when the button is clicked
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for public_profile permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info", @"email"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             // Retrieve the app delegate
             AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
             // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
             [appDelegate sessionStateChanged:session state:state error:error];
         }];
    }
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

- (void)userLoggedIn
{
    NSLog(@"FB Logged in");
   
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             if (!error) {
                NSLog(@"FB log in info");
                NSString *firstName = user.first_name;
                NSString *lastName = user.last_name;
                NSString *facebookId = user.id;
                NSString *location = user.location.name;
                NSString *zip = @"";
                NSString *email = [user objectForKey:@"email"];
                NSString *accessToken = [[[FBSession activeSession] accessTokenData] accessToken];
                NSString *loginEmail = [NSString stringWithFormat:@"%@@fb", email];
                NSLog(@"FB profile fetched ... %@, %@, %@", user, loginEmail, accessToken);
    
                [[MLApiClient client] loginWithFB:email
                                      accessToken:accessToken
                                        firstName:firstName
                                         lastName:lastName
                                             fbId:facebookId
                                         location:location
                                              zip:zip
                                          success:^(NSHTTPURLResponse *response, id responseJSON) {
                                              NSLog(@"!!!!!FB Login succeeded!!!!, %@", responseJSON);
                                              [[MLApiClient client] setLoggedInInfoWithEmail:loginEmail
                                                                                    password:accessToken
                                                                                      userId:[responseJSON[@"id"] integerValue]];
                                              [self subscribePush:[responseJSON[@"id"] integerValue]];
                                              if (response.statusCode == 201) {
                                                  // just created new user, need to upload photo
                                                  NSLog(@"new FB user created!!!");
                                                  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                  [defaults setObject:@(YES) forKey:@"firstSignup"];
                                                  [defaults synchronize];
                                              }


                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  [self performSegueWithIdentifier:@"MainFeed" sender:self];
                                              });
                                          } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
                                              NSLog(@"!!!!!FB Login failed!!!!, %@", responseJSON);
                                          }];
             }
         }];
    }

}

- (void)userLoggedOut
{
    NSLog(@"FB Logged out");
}

- (void)subscribePush:(NSInteger)userId
{
    NSString *parseChannel = [NSString stringWithFormat:@"user_%d", userId];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:parseChannel forKey:@"channels"];
    [currentInstallation saveInBackground];
}

@end
