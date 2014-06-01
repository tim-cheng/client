//
//  MLUserInfo.h
//  test1
//
//  Created by Tim Cheng on 5/4/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^MLUserInfoSuccess)(id responseJSON);


@interface MLUserInfo : NSObject

+ (MLUserInfo *)instance;
- (void) userInfoFromId:(NSInteger)userId success:(MLUserInfoSuccess)callback;
- (void) invalidateUserInfoFromId:(NSInteger)userId;
- (UIImage *)userPicture:(NSInteger)userId;


@end

