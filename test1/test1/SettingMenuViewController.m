//
//  SettingMenuViewController.m
//  test1
//
//  Created by Tim Cheng on 5/15/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "SettingMenuViewController.h"
#import "MLUserInfo.h"
#import "MLApiClient.h"
#import "MainFeedViewController.h"
#import "ActivityTableViewController.h"
#import "UserProfileViewController.h"
#import "InviteViewController.h"


@interface SettingMenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *profPicView;
@property (strong, nonatomic) IBOutlet UITableView *settingsView;

@property (strong, nonatomic) NSArray *iconArray;
@property (strong, nonatomic) NSArray *labelArray;
@end

@implementation SettingMenuViewController

- (void) viewDidLoad
{
    self.view.backgroundColor = [UIColor clearColor];
    self.profPicView.image = [[MLUserInfo instance] userPicture:[MLApiClient client].userId];
    self.profPicView.backgroundColor = [UIColor redColor];
    
    self.settingsView.dataSource = self;
    self.settingsView.delegate = self;
    self.iconArray = @[
                       [UIImage imageNamed:@"profile_96.png"],
                       [UIImage imageNamed:@"profile_96.png"],
                       [UIImage imageNamed:@"connect_96.png"],
                       [UIImage imageNamed:@"message_96.png"],
                       [UIImage imageNamed:@"logout_96.png"],
                       ];
    self.labelArray = @[
                        @"Feed",
                        @"Profile",
                        @"Connections",
                        @"Activities",
                        @"Logout",
                        ];
}

#pragma mark - UITableViewDataSource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SettingCell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }

    int idx = indexPath.row;
    
    UIImageView *icon = (UIImageView *)[cell.contentView viewWithTag:10];
    icon.image = self.iconArray[idx];
    
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:11];
    label.text = self.labelArray[idx];
    
    return cell;

}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        MainFeedViewController *profileController = [self.storyboard instantiateViewControllerWithIdentifier:@"feedController"];
        navigationController.viewControllers = @[profileController];
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        UserProfileViewController *profileController = [self.storyboard instantiateViewControllerWithIdentifier:@"profileController"];
        navigationController.viewControllers = @[profileController];
    } else if (indexPath.section == 0 && indexPath.row == 2) {
        InviteViewController *contactController = [self.storyboard instantiateViewControllerWithIdentifier:@"contactController"];
        navigationController.viewControllers = @[contactController];
    } else if (indexPath.section == 0 && indexPath.row == 3) {
        ActivityTableViewController *activityController = [self.storyboard instantiateViewControllerWithIdentifier:@"activityController"];
        navigationController.viewControllers = @[activityController];
    } else if (indexPath.section == 0 && indexPath.row == 4) {
        [FBSession.activeSession closeAndClearTokenInformation];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:nil forKey:@"savedPosts"];
        [defaults synchronize];
        [self dismissViewControllerAnimated:NO completion:^{
            [self.frostedViewController performSegueWithIdentifier:@"LogoutMain" sender:self.frostedViewController];
        }];
    }
    self.frostedViewController.contentViewController = navigationController;
    [self.frostedViewController hideMenuViewController];
}


@end
