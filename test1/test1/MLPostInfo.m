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

@property (strong, nonatomic) NSDictionary *pendingPost;

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


- (void) postInfoFromId:(NSInteger)userId
                   body:(NSString *)body
                  image:(UIImage *)image
                bgColor:(UIColor *)bgColor
                success:(MLPostInfoSuccess)callback
{
    [[MLApiClient client] sendPostFromId:userId
                                    body:body
                                 bgColor:bgColor
                                 success:^(NSHTTPURLResponse *response, id responseJSON) {
                                     int postId = [responseJSON[@"id"] intValue];
                                     if (image) {
                                         self.postPictureCache[@(postId)] = image;
                                         // save the background
                                         [[MLApiClient client] sendPostPictureId:[responseJSON[@"id"] integerValue]
                                                                           image:image
                                                                         success:^(NSHTTPURLResponse *response, id responseJSON) {
                                                                             if (callback) {
                                                                                 callback(responseJSON);
                                                                             }
                                                                         } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
                                                                             NSLog(@"failed to post picture");
                                                                         }];
                                     } else {
                                         if (callback) {
                                             callback(responseJSON);
                                         }
                                     }
                                 } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
                                     
                                 }];
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

- (void) loadPostInfoFromId:(NSInteger)userId
                     degree:(NSInteger)degree
                    success:(MLPostInfoSuccess)callback
{
    [[MLApiClient client] postsFromId:userId
                               degree:degree
                              success:^(NSHTTPURLResponse *response, id responseJSON) {
                                  NSLog(@"!!!!get posts succeeded!!!!, %@", responseJSON);
                                  if (callback ) {
                                      callback(responseJSON);
                                  }
                              } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
                                  NSLog(@"!!!!!get posts failed");
                              }];
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
