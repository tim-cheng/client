//
//  FindUserViewController.m
//  test1
//
//  Created by Tim Cheng on 5/18/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "FindUserViewController.h"
#import "MLApiClient.h"

@interface FindUserViewController () <UITableViewDataSource, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *resultsView;

- (IBAction)tapBack:(id)sender;
@end

@implementation FindUserViewController


- (void)viewDidLoad
{
    self.searchBar.delegate = self;
    self.resultsView.dataSource = self;
}

- (IBAction)tapBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
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
    } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
        NSLog(@"search failed: %@", responseJSON);
    }];
}
@end
