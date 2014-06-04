//
//  FindUserViewController.m
//  test1
//
//  Created by Tim Cheng on 5/18/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "FindUserViewController.h"
#import "MLApiClient.h"
#import "MLUserInfo.h"

@interface FindUserViewController () <UITableViewDataSource, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *resultsView;
@property (strong, nonatomic) NSMutableArray *userIds;

- (IBAction)tapBack:(id)sender;
- (IBAction)tapInvite:(UIButton *)button;
@end

@implementation FindUserViewController


- (void)viewDidLoad
{
    self.userIds = [[NSMutableArray alloc] init];
    self.searchBar.delegate = self;
    self.resultsView.dataSource = self;
}

- (void)clearUsers
{
    if ([self.userIds count] > 0) {
        [self.resultsView beginUpdates];
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        for (int i=0; i<[self.userIds count]; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        [self.resultsView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [self.userIds removeAllObjects];
        [indexPaths removeAllObjects];
        [self.resultsView endUpdates];
    }
}

- (void)loadUsers
{
    [self.resultsView beginUpdates];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (int i=0; i<[self.userIds count]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self.resultsView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.resultsView endUpdates];
}

- (IBAction)tapBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.userIds count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FindUserCell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }

    NSDictionary *userInfo = (NSDictionary *)self.userIds[indexPath.row];
    NSInteger userId = [userInfo[@"id"] integerValue];
    cell.tag = userId;
    UIImageView *pic = (UIImageView *)[cell.contentView viewWithTag:10];
    if (pic) {
        pic.image = [[MLUserInfo instance] userPicture:userId];
    }
    
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:11];
    if (nameLabel) {
        nameLabel.text = [NSString stringWithFormat:@"%@ %@", userInfo[@"first_name"], userInfo[@"last_name"]];
    }
    
    UILabel *locationLabel = (UILabel *)[cell.contentView viewWithTag:12];
    if (locationLabel) {
        locationLabel.text = @"San Jose, California";
    }
    
    UIButton *inviteButton = (UIButton *)[cell.contentView viewWithTag:13];
    if (inviteButton) {
        inviteButton.imageView.image = [UIImage imageNamed:@"adduser_64.png"];
    }
    return cell;
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"start editing");
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [[MLApiClient client] findUser:searchBar.text success:^(NSHTTPURLResponse *response, id responseJSON) {
        NSLog(@"search success: %@", (NSDictionary *)responseJSON);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self clearUsers];
            [self.userIds addObjectsFromArray:responseJSON];
            [self loadUsers];
        });
    } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
        NSLog(@"search failed: %@", responseJSON);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self clearUsers];
            [self.view endEditing:YES];
        });
    }];
}

#pragma mark - IBAction
- (IBAction)tapInvite:(UIButton *)button
{
    NSLog(@"tapped invite");
    
    NSInteger inviteUser = [[[button superview] superview] superview].tag;
    [[MLApiClient client] inviteUserFromId:kApiClientUserSelf inviteId:inviteUser success:^(NSHTTPURLResponse *response, id responseJSON) {
        NSLog(@"user %d invited", inviteUser);
        dispatch_async(dispatch_get_main_queue(), ^{
            button.imageView.image = [UIImage imageNamed:@"check_64.png"];
        });
    } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
        NSLog(@"user invite failed");
    }];
}

@end
