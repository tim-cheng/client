//
//  LoginUIViewController.m
//  test1
//
//  Created by Tim Cheng on 3/24/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "LoginUIViewController.h"
#import "StatusUpdateViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface LoginUIViewController() <FBLoginViewDelegate>

@property (strong,nonatomic) StatusUpdateViewController *statusVC;

@end

@implementation LoginUIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //FBLoginView *loginView = [[FBLoginView alloc] init];
    
    FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions:@[@"basic_info", @"email", @"user_about_me"]];
    
    // Align the button in the center horizontally
    loginView.frame = CGRectOffset(loginView.frame, (self.view.center.x - (loginView.frame.size.width / 2)), (self.view.center.y - (loginView.frame.size.height / 2)));
    
    loginView.delegate = self;
    
    [self.view addSubview:loginView];
}

#pragma mark FBLoginViewDelegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    NSLog(@"FB logged in ... ");
    [self performSegueWithIdentifier:@"LoggedIn" sender:self];
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user
{
    NSLog(@"FB profile fetched ... ");
    if (self.statusVC) {
        [self.statusVC updateUserInfo:loginView user:user];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"LoggedIn"]) {
        self.statusVC = ([segue.destinationViewController isKindOfClass:[StatusUpdateViewController class]]) ? segue.destinationViewController : nil;
//        controller.subject = ([sender isKindOfClass:[Subject class]]) ? subject : nil;
        NSLog(@"ready to segue");
        
    }
}

@end
