//
//  MainNavigationController.h
//  test1
//
//  Created by Tim Cheng on 5/26/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainNavigationController : UINavigationController

- (void)switchToFeedAtId:(NSInteger)postId;
- (void)switchToFeedAtId:(NSInteger)postId andUserId:(NSInteger)userId andDegree:(NSInteger)degree;
- (void)switchToProfileForUserId:(NSInteger)userId;
@end
