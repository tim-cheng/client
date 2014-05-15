//
//  InviteViewController.m
//  test1
//
//  Created by Tim Cheng on 5/14/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "InviteViewController.h"

@interface InviteViewController ()

- (IBAction)finishInvite:(id)sender;

@end

@implementation InviteViewController


- (IBAction)finishInvite:(id)sender
{
    [self performSegueWithIdentifier:@"FinishInvite" sender:self];
}

@end
