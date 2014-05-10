//
//  MLPostInfo.m
//  test1
//
//  Created by Tim Cheng on 5/10/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "MLPostInfo.h"
#import "MLApiClient.h"

@interface MLPostInfo ()

@property (strong, nonatomic) NSMutableDictionary *postInfoCache;
@property (strong, nonatomic) NSMutableDictionary *postPictureCache;

@end

@implementation MLPostInfo

+ (MLPostInfo *)instance
{
    static MLPostInfo *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MLPostInfo alloc] init];
    });
    return sharedInstance;
}

- (void) postInfoFromId:(NSInteger)postId success:(MLPostInfoSuccess)callback
{
    
}

- (UIImage *)postPicture:(NSInteger)postId
{
    if (self.postPictureCache[@(postId)]) {
        return self.postPictureCache[@(postId)];
    } else {
        NSURL *url = [[MLApiClient client] postPictureUrl:postId];
        if (url) {
            NSData *imageData = [NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:imageData scale:2.0f];
            if (image) {
                self.postPictureCache[@(postId)] = image;
            }
            return image;
        }
    }
    return nil;
}

- (id) init
{
    self = [super init];
    if (self) {
        self.postInfoCache = [[NSMutableDictionary alloc] init];
        self.postPictureCache = [[NSMutableDictionary alloc] init];
    }
    return self;
}

@end
