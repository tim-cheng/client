//
//  MainNavigationController.m
//  test1
//
//  Created by Tim Cheng on 5/26/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "MainNavigationController.h"
#import "MainFeedViewController.h"

@interface MainNavigationController()
-(IBAction)tapBackToFeed:(id)sender;
-(IBAction)tapSaveProfile:(id)sender;


@end

@implementation MainNavigationController

-(IBAction)tapBackToFeed:(id)sender
{
    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    
    MainFeedViewController *feedController = [self.storyboard instantiateViewControllerWithIdentifier:@"feedController"];
    navigationController.viewControllers = @[feedController];
    self.frostedViewController.contentViewController = navigationController;
}

-(IBAction)tapSaveProfile:(id)sender
{
    NSLog(@"tap save...");
}


@end
