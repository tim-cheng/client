//
//  MainNavigationController.m
//  test1
//
//  Created by Tim Cheng on 5/26/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "MainNavigationController.h"
#import "MainFeedViewController.h"
#import "AddChildViewController.h"
#import "UserProfileViewController.h"

@interface MainNavigationController()
-(IBAction)tapBackToFeed:(id)sender;
-(IBAction)tapSaveProfile:(id)sender;
-(IBAction)tapDoneChild:(id)sender;


@end

@implementation MainNavigationController

-(IBAction)tapBackToFeed:(id)sender
{
    [self switchToFeedAtId:0];
}

- (void)switchToFeedAtId:(NSInteger)postId
{
    NSLog(@"switch to post_id: %d", postId);
    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    
    MainFeedViewController *feedController = [self.storyboard instantiateViewControllerWithIdentifier:@"feedController"];
    
    feedController.initPostId = postId;
    navigationController.viewControllers = @[feedController];
    self.frostedViewController.contentViewController = navigationController;
}

- (void)switchToProfileForUserId:(NSInteger)userId
{
    NSLog(@"switch to profile for user_id: %d", userId);
    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    
    UserProfileViewController *profController = [self.storyboard instantiateViewControllerWithIdentifier:@"profileController"];
    profController.userId = userId;
    
    navigationController.viewControllers = @[profController];
    self.frostedViewController.contentViewController = navigationController;
}

-(IBAction)tapSaveProfile:(id)sender
{
    NSLog(@"tap save...");
}

-(IBAction)tapDoneChild:(id)sender
{
    NSLog(@"tap done child");
    AddChildViewController *vc = (AddChildViewController *)self.topViewController;
    [vc doneChild];
}


@end
