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
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "MLApiClient.h"
#import "MLUserInfo.h"
#import "MLHelpers.h"
#import "CustomUILabel.h"
#import "MainNavigationController.h"
#import "CMPopTipView.h"


@interface InviteViewController () <ABPeoplePickerNavigationControllerDelegate,
                                    UITableViewDataSource, UITableViewDelegate, CMPopTipViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *contactView;
@property (strong, nonatomic) NSMutableArray *inviterArray;
@property (strong, nonatomic) NSMutableArray *connectionArray;
@property (strong, nonatomic) CMPopTipView *oobeTip;
@property (strong, nonatomic) IBOutlet UIButton *findButton;

- (IBAction)selectFacebook:(id)sender;
- (IBAction)selectEmail:(id)sender;
- (IBAction)findUser:(id)sender;
- (IBAction)tapAccept:(UIButton *)button;
@end

@implementation InviteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.inviterArray = [[NSMutableArray alloc] init];
    self.connectionArray = [[NSMutableArray alloc] init];
    self.contactView.dataSource = self;
    self.contactView.delegate = self;
    [self loadContacts];
    
    //  add tooltip for firstSignup
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *firstSignup= [defaults objectForKey:@"firstSignup"];
    if (firstSignup && [firstSignup boolValue]) {
        self.oobeTip = [[CMPopTipView alloc] initWithMessage:@"Almost there... Now invite existing parents to connect."];
        self.oobeTip.delegate = self;
        self.oobeTip.has3DStyle = NO;
        self.oobeTip.hasGradientBackground = NO;
        self.oobeTip.backgroundColor = MLColor;
        self.oobeTip.textColor = [UIColor whiteColor];
        self.oobeTip.textFont = [UIFont fontWithName:@"bariol-regular" size:17.0];
        self.oobeTip.borderWidth = 0;
        [self.oobeTip presentPointingAtView:self.findButton inView:self.view animated:YES];
        [defaults setObject:@(NO) forKey:@"firstSignup"];
        [defaults synchronize];
    }

}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void) clearContacts
{
    [self.contactView beginUpdates];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (int i=0; i<[self.inviterArray count]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    for (int i=0; i<[self.connectionArray count]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:1]];
    }
    [self.contactView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.inviterArray removeAllObjects];
    [self.connectionArray removeAllObjects];
    [self.contactView endUpdates];
}


- (void)loadContacts
{
    [self clearContacts];
    
    [[MLApiClient client] invitesForId:kApiClientUserSelf success:^(NSHTTPURLResponse *response, id responseJSON) {
        NSLog(@"received invites: %@", responseJSON);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.contactView beginUpdates];
            [self.inviterArray addObjectsFromArray:responseJSON];
            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
            for (int i=0; i<[self.inviterArray count]; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            [self.contactView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [self.contactView endUpdates];
        });
    } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
        NSLog(@"no invites");
    }];

    [[MLApiClient client] connectionsForId:kApiClientUserSelf success:^(NSHTTPURLResponse *response, id responseJSON) {
        NSLog(@"received connections: %@", responseJSON);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.contactView beginUpdates];
            [self.connectionArray addObjectsFromArray:responseJSON];
            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
            for (int i=0; i<[self.connectionArray count]; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:1]];
            }
            [self.contactView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [self.contactView endUpdates];
        });
        
    } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
        NSLog(@"no connections");
    }];

}

#pragma mark - IBAction
- (IBAction)selectEmail:(id)sender
{
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    // Display only a person's phone, email, and birthdate
    NSArray *displayedItems = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonPhoneProperty],
                               [NSNumber numberWithInt:kABPersonEmailProperty],
                               [NSNumber numberWithInt:kABPersonBirthdayProperty], nil];
    
    
    picker.displayedProperties = displayedItems;
    // Show the picker
    [self presentViewController:picker animated:YES completion:nil];
    
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
    
    [FBWebDialogs
     presentRequestsDialogModallyWithSession:nil
     message:@"Download and try Parent2D"
     title:@"Invite Users"
     parameters:nil
     handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error) {
             // Error launching the dialog or sending the request.
             NSLog(@"Error sending request.");
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 // User clicked the "x" icon
                 NSLog(@"User canceled request.");
             } else {
                 // Handle the send request callback
                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                 if (![urlParams valueForKey:@"request"]) {
                     // User clicked the Cancel button
                     NSLog(@"User canceled request.");
                 } else {
                     // User clicked the Send button
                     NSString *requestID = [urlParams valueForKey:@"request"];
                     NSLog(@"Request ID: %@", requestID);
                 }
             }
         }
     }];
}

- (IBAction)findUser:(id)sender
{
    [self performSegueWithIdentifier:@"FindUser" sender:self];
}

- (IBAction)tapAccept:(UIButton *)button
{
    NSLog(@"accept request");
    NSInteger inviteUser = [[[button superview] superview] superview].tag;
    [[MLApiClient client] acceptInviteUserFromId:inviteUser inviteId:kApiClientUserSelf success:^(NSHTTPURLResponse *response, id responseJSON) {
        NSLog(@"accept invite success");
        [self loadContacts];
    } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
        NSLog(@"accept invite failure");
    }];
    
}


#pragma mark ABPeoplePickerNavigationControllerDelegate methods
// Displays the information of a selected person
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    return YES;
}

// Does not allow users to perform default actions such as dialing a phone number, when they select a person property.
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

// Dismisses the people picker and shows the application when users tap Cancel.
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker;
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
    
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Pending Requests";
    } else {
        return @"Connections";
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.inviterArray count];
    } else {
        return [self.connectionArray count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ContactUserCell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *userInfo;
    if (indexPath.section == 0) {
        userInfo = (NSDictionary *)self.inviterArray[indexPath.row];
    } else {
        userInfo = (NSDictionary *)self.connectionArray[indexPath.row];
    }
    
    NSInteger userId = [userInfo[@"user_id"] integerValue];
    cell.tag = userId;
    UIImageView *pic = (UIImageView *)[cell.contentView viewWithTag:10];
    if (pic) {
        pic.image = [[MLUserInfo instance] userPicture:userId];
        pic.layer.borderWidth = 1.0f;
        pic.layer.borderColor = [MLColor CGColor];
        pic.layer.cornerRadius = 20;
        pic.clipsToBounds = YES;
    }
    
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:11];
    if (nameLabel) {
        nameLabel.text = [NSString stringWithFormat:@"%@ %@", userInfo[@"first_name"], userInfo[@"last_name"]];
    }
    
    UILabel *locationLabel = (UILabel *)[cell.contentView viewWithTag:12];
    if (locationLabel) {
        [[MLUserInfo instance] userInfoFromId:userId success:^(id responseJSON) {
            dispatch_async(dispatch_get_main_queue(), ^{
                locationLabel.text = responseJSON[@"location"];
            });
        }];
    }
    
    UIButton *inviteButton = (UIButton *)[cell.contentView viewWithTag:13];
    if (indexPath.section == 1) {
        inviteButton.hidden = YES;
    } else {
        inviteButton.hidden = NO;
    }
//    if (inviteButton) {
//        inviteButton.imageView.image = [UIImage imageNamed:@"adduser_64.png"];
//    }
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0 && [self.inviterArray count] == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0)];
        return view;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    CustomUILabel *label = [[CustomUILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    label.font = [UIFont fontWithName:@"bariol-regular" size:14];
    label.textColor = MLColorBrown;

    if (section == 0) {
        [label setText:@"Pending Requests"];
    } else {
        [label setText:@"Connections"];
    }
    [view addSubview:label];
    [view setBackgroundColor:[UIColor whiteColor]];
    return view;
}



#pragma mark - helper

- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [[kv objectAtIndex:1]
         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}

#pragma mark CMPopTipViewDelegate methods
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    self.oobeTip = nil;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *userInfo;
    if (indexPath.section == 0) {
        userInfo = (NSDictionary *)self.inviterArray[indexPath.row];
    } else {
        userInfo = (NSDictionary *)self.connectionArray[indexPath.row];
    }
    NSInteger userId = [userInfo[@"user_id"] integerValue];
    MainNavigationController *nav = (MainNavigationController *)self.navigationController;
    [nav switchToProfileForUserId:userId];
}

@end
