//
//  UserProfileViewController.m
//  test1
//
//  Created by Tim Cheng on 5/18/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "UserProfileViewController.h"
#import "MainFeedViewController.h"

@interface UserProfileViewController ()

-(IBAction)tapBack:(id)sender;
@end

@implementation UserProfileViewController

-(IBAction)tapBack:(id)sender
{
    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    
    MainFeedViewController *feedController = [self.storyboard instantiateViewControllerWithIdentifier:@"feedController"];
    navigationController.viewControllers = @[feedController];
    self.frostedViewController.contentViewController = navigationController;

}

@end
