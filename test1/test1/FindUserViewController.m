//
//  FindUserViewController.m
//  test1
//
//  Created by Tim Cheng on 5/18/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "FindUserViewController.h"

@interface FindUserViewController () <UITableViewDataSource>

- (IBAction)tapBack:(id)sender;
@end

@implementation FindUserViewController


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
@end
