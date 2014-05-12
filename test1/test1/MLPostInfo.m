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

- (void) postPicture:(NSInteger)postId
                 success:(MLPostPictureSuccess)callback
{
    if (self.postPictureCache[@(postId)]) {
        if (callback) {
            callback(self.postPictureCache[@(postId)]);
        }
    } else {
        [[MLApiClient client] postPictureFromeId:postId
                                         success:^(NSHTTPURLResponse *response, NSData *data) {
                                             UIImage *image = [UIImage imageWithData:data scale:2.0f];
                                             if (image) {
                                                 self.postPictureCache[@(postId)] = image;
                                             }
                                             if (callback) {
                                                 callback(image);
                                             }
                                         } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
                                             NSLog(@"failed to load picture");
                                         }];
    }
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
