//
//  MainRootViewController.m
//  test1
//
//  Created by Tim Cheng on 5/15/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "MainRootViewController.h"

@implementation MainRootViewController

- (void)awakeFromNib
{
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menuController"];
}

@end
