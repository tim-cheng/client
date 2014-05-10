//
//  MLPostInfo.h
//  test1
//
//  Created by Tim Cheng on 5/10/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MLPostInfoSuccess)(id responseJSON);

@interface MLPostInfo : NSObject

+ (MLPostInfo *)instance;
- (void) postInfoFromId:(NSInteger)postId success:(MLPostInfoSuccess)callback;
- (UIImage *)postPicture:(NSInteger)postId;

@end
