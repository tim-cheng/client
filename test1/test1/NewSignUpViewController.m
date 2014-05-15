//
//  NewSignUpViewController.m
//  test1
//
//  Created by Tim Cheng on 5/14/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "NewSignUpViewController.h"

@interface NewSignUpViewController ()

- (IBAction)nextStep:(id)sender;
- (IBAction)addChild:(id)sender;

@end

@implementation NewSignUpViewController


- (IBAction)nextStep:(id)sender
{
    [self performSegueWithIdentifier:@"InviteUser" sender:self];
}

- (IBAction)addChild:(id)sender
{
    [self performSegueWithIdentifier:@"AddChild" sender:self];
}

@end
