//
//  AddChildViewController.h
//  test1
//
//  Created by Tim Cheng on 5/14/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddChildViewController : UIViewController

@property (assign, nonatomic) NSInteger kidId;
@property (strong, nonatomic) NSString *kidName;
@property (strong, nonatomic) NSString *kidBirthday;
@property (assign, nonatomic) BOOL kidIsBoy;

- (void)doneChild;

@end

