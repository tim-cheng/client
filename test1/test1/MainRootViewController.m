//
//  MainRootViewController.m
//  test1
//
//  Created by Tim Cheng on 5/15/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "MainRootViewController.h"
#import "UserProfileViewController.h"

@implementation MainRootViewController

- (void)awakeFromNib
{
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menuController"];
}

- (void) viewDidLoad
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *firstSignup= [defaults objectForKey:@"firstSignup"];
    if (firstSignup && [firstSignup boolValue]) {
        UserProfileViewController *profController = [self.storyboard instantiateViewControllerWithIdentifier:@"profileController"];
        UINavigationController *navigationController = (UINavigationController *)self.contentViewController;
        navigationController.viewControllers = @[profController];
        self.contentViewController = navigationController;
    }
//    [defaults setObject:@(NO) forKey:@"firstSignup"];
//    [defaults synchronize];
}

@end
