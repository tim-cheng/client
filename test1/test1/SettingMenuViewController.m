//
//  SettingMenuViewController.m
//  test1
//
//  Created by Tim Cheng on 5/15/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "SettingMenuViewController.h"
#import "MLUserInfo.h"
#import "MLApiClient.h"

@interface SettingMenuViewController () <UITableViewDataSource>

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
    
    self.settingsView.dataSource = self;
    self.iconArray = @[
                       [UIImage imageNamed:@"profile_96.png"],
                       [UIImage imageNamed:@"message_96.png"],
                       [UIImage imageNamed:@"setting_96.png"],
                       [UIImage imageNamed:@"connect_96.png"],
                       [UIImage imageNamed:@"support_96.png"],
                       ];
    self.labelArray = @[
                        @"Profile",
                        @"Message",
                        @"Setting",
                        @"Invite",
                        @"Support",
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

@end
