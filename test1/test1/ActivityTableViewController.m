//
//  ActivityTableViewController.m
//  test1
//
//  Created by Tim Cheng on 5/18/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "ActivityTableViewController.h"
#import "MainFeedViewController.h"
#import "MainNavigationController.h"
#import "MLUserInfo.h"
#import "MLApiClient.h"
#import "MLHelpers.h"

@interface ActivityTableViewController ()

@property (strong, nonatomic) NSMutableArray *activityArray;

@end

@implementation ActivityTableViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.activityArray = [[NSMutableArray alloc] init];
    
    [[MLApiClient client] activitiesForId:kApiClientUserSelf success:^(NSHTTPURLResponse *response, id responseJSON) {
        NSLog(@"received activities %@", responseJSON);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self clearActivities];
            [self.activityArray addObjectsFromArray:responseJSON];
            [self.tableView beginUpdates];
            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
            for (int i=0; i<[self.activityArray count]; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        });
    } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
        NSLog(@"no activities");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self clearActivities];
        });
    }];
    
}

- (void)clearActivities
{
    if ([self.activityArray count] > 0) {
        [self.tableView beginUpdates];
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        for (int i=0; i<[self.activityArray count]; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [self.activityArray removeAllObjects];
        [indexPaths removeAllObjects];
        [self.tableView endUpdates];
    }
}


#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.activityArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ActivityCell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *userInfo = self.activityArray[indexPath.row];
    UIImageView *picView = (UIImageView *)[cell.contentView viewWithTag:10];
    picView.image = [[MLUserInfo instance] userPicture:[userInfo[@"friend_id"] integerValue]];
    picView.layer.borderWidth = 1.0f;
    picView.layer.borderColor = [MLColor CGColor];
    picView.layer.cornerRadius = 16;
    picView.clipsToBounds = YES;

    
    UILabel *labelView = (UILabel *)[cell.contentView viewWithTag:11];
    labelView.text = userInfo[@"activity"];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSNumber *postId = self.activityArray[indexPath.row][@"post_id"];
    if (postId)  {
        NSLog(@"select post: %d", [postId integerValue]);
        MainNavigationController *nav = (MainNavigationController *)self.navigationController;
        [nav switchToFeedAtId:[postId integerValue]];
    }
}


@end
