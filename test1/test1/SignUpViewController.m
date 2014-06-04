//
//  SignUpViewController.m
//  test1
//
//  Created by Tim Cheng on 3/28/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "SignUpViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "DBClient.h"

@interface SignUpViewController ()

@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (strong, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *lastNameLabel;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;

@property (strong, nonatomic) NSString *fbId;
@property (strong, nonatomic) NSString *userId;


- (IBAction) completeSignUp:(id)sender;
- (IBAction) backToLogIn:(id)sender;

@end

@implementation SignUpViewController

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
    // Do any additional setup after loading the view.
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
    self.profilePictureView.layer.cornerRadius = 20.0f;
    
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
            
            if (!error) {
                NSLog(@"user: %@", user);
                self.firstNameLabel.text = user[@"first_name"];
                self.lastNameLabel.text = user[@"last_name"];
                self.emailField.text = user[@"email"];
                self.fbId = user[@"id"];
            }
        }];
    }
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(changePhoto:)];
    [self.profilePictureView addGestureRecognizer:singleFingerTap];
    
}

- (void)changePhoto:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"Change Photo...");
}

- (IBAction) completeSignUp:(id)sender
{
    NSLog(@"Complete SignUp");
    
    
    [[DBClient client].firebaseAuth createUserWithEmail:self.emailField.text password:self.passwordField.text
                 andCompletionBlock:^(NSError* error, FAUser* user) {
                     if (error != nil) {
                         // There was an error creating the account
                         NSLog(@"failed to create account; %@, %@", error, self.emailField.text);
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to create Account"
                                                                         message:[error description]
                                                                        delegate:nil
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles:nil];
                         [alert show];
                     } else {
                         // We created a new user account
                         NSLog(@"created account for user; %@", self.emailField.text);
                         NSLog(@"user: uid=%@, userId=%@", user.uid, user.userId);
                         self.userId = user.userId;
                         
                         [self accountCreated];
                     }

                 }];
    
}

- (void) accountCreated
{
    // create record
    
    [[DBClient client].firebaseAuth loginWithEmail:self.emailField.text andPassword:self.passwordField.text
           withCompletionBlock:^(NSError* error, FAUser* user) {
               
               if (error != nil) {
                   // There was an error logging in to this account
               } else {
                   // We are now logged in
                   [[DBClient refForUserId:self.userId] setValue:@{ @"profile" : @{
                                                       @"first_name" : self.firstNameLabel.text,
                                                       @"last_name" : self.lastNameLabel.text,
                                                       @"email" : self.emailField.text,
                                                       @"fb_id" : self.fbId,
                                                       @"friend" : @[],
                                                       },
                                       @"post" : @[]
                                       }];
                   
                   if (self.fbId) {
                       [[DBClient refForFBUserId:self.fbId] setValue:@{@"id" : self.userId}];
                   }
                   
                   [DBClient client].loggedInUserId = self.userId;
                   [self proceedToConnect];
               }
           }];
}

- (void) proceedToConnect
{
    [self performSegueWithIdentifier:@"ConnectAccount" sender:self];
}

- (IBAction) backToLogIn:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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

@end
