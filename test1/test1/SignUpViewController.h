//
//  SignUpViewController.h
//  test1
//
//  Created by Tim Cheng on 3/28/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface SignUpViewController : UIViewController

- (void)updateUserInfo:(FBLoginView *)loginView
                  user:(id<FBGraphUser>)user;

@end
