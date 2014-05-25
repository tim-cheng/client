//
//  AddChildViewController.m
//  test1
//
//  Created by Tim Cheng on 5/14/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "AddChildViewController.h"


@interface AddChildViewController ()

-(IBAction)tapDone:(id)sender;
-(IBAction)tapBack:(id)sender;

@end
@implementation AddChildViewController

-(IBAction)tapDone:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)tapBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
