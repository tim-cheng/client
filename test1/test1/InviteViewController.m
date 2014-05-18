//
//  InviteViewController.m
//  test1
//
//  Created by Tim Cheng on 5/14/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "InviteViewController.h"
#import "MainFeedViewController.h"


@interface InviteViewController () <FBFriendPickerDelegate>

@property (strong, nonatomic) FBFriendPickerViewController *friendPickerController;

- (IBAction)tapBack:(id)sender;
- (IBAction)selectFacebook:(id)sender;

@end

@implementation InviteViewController

- (void)viewDidUnload {
    self.friendPickerController = nil;
    [super viewDidUnload];
}


#pragma mark - IBAction
- (IBAction)tapBack:(id)sender
{
    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    
    MainFeedViewController *feedController = [self.storyboard instantiateViewControllerWithIdentifier:@"feedController"];
    navigationController.viewControllers = @[feedController];
    self.frostedViewController.contentViewController = navigationController;
}

- (IBAction)selectFacebook:(id)sender
{
    // FBSample logic
    // if the session is open, then load the data for our view controller
    if (!FBSession.activeSession.isOpen) {
        // if the session is closed, then we open it here, and establish a handler for state changes
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"user_friends"]
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session,
                                                          FBSessionState state,
                                                          NSError *error) {
                                          if (error) {
                                              UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                  message:error.localizedDescription
                                                                                                 delegate:nil
                                                                                        cancelButtonTitle:@"OK"
                                                                                        otherButtonTitles:nil];
                                              [alertView show];
                                          } else if (session.isOpen) {
                                              [self selectFacebook:sender];
                                          }
                                      }];
        return;
    }
    
    if (self.friendPickerController == nil) {
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Pick Friends";
        self.friendPickerController.delegate = self;
    }
    
    [self.friendPickerController loadData];
    [self.friendPickerController clearSelection];
    
    [self presentViewController:self.friendPickerController animated:YES completion:nil];
}

#pragma mark - FBFriendPickerDelegate

- (void)facebookViewControllerDoneWasPressed:(id)sender {
    NSMutableString *text = [[NSMutableString alloc] init];
    
    // we pick up the users from the selection, and create a string that we use to update the text view
    // at the bottom of the display; note that self.selection is a property inherited from our base class
    for (id<FBGraphUser> user in self.friendPickerController.selection) {
        if ([text length]) {
            [text appendString:@", "];
        }
        [text appendString:user.name];
    }
    
    [self fillTextBoxAndDismiss:text.length > 0 ? text : @"<None>"];
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
    [self fillTextBoxAndDismiss:@"<Cancelled>"];
}

- (void)fillTextBoxAndDismiss:(NSString *)text {
//    self.selectedFriendsView.text = text;
    NSLog(@"selected following friends: %@", text);
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
