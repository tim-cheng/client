//
//  MLPostInfo.h
//  test1
//
//  Created by Tim Cheng on 5/10/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MLPostInfoSuccess)(id responseJSON);
typedef void (^MLPostPictureSuccess)(UIImage *responseImage);

@interface MLPostInfo : NSObject

+ (MLPostInfo *)instance;
- (void) postPicture:(NSInteger)postId
                 success:(MLPostPictureSuccess)callback;

- (void) postInfoFromId:(NSInteger)userId
                   body:(NSString *)body
                  image:(UIImage *)image
                bgColor:(UIColor *)bgColor
                success:(MLPostInfoSuccess)callback;

- (void) loadPostInfoFromId:(NSInteger)userId
                     degree:(NSInteger)degree
                    success:(MLPostInfoSuccess)callback;


@end
