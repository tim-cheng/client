//
//  MLUserInfo.m
//  test1
//
//  Created by Tim Cheng on 5/4/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "MLUserInfo.h"
#import "MLApiClient.h"

@interface MLUserInfo ()

@property (strong, nonatomic) NSMutableDictionary *userInfoCache;
@property (strong, nonatomic) NSMutableDictionary *userPictureCache;

@end

@implementation MLUserInfo

+ (MLUserInfo *)instance
{
    static MLUserInfo *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MLUserInfo alloc] init];
    });
    return sharedInstance;
}

- (void) userInfoFromId:(NSInteger)userId success:(MLUserInfoSuccess)callback
{
    NSDictionary *dict = self.userInfoCache[@(userId)];
    if (dict) {
        // already cached
        if (callback) {
            callback(dict);
        }
    } else {
        // doesn't exist, try to fetch
        [[MLApiClient client] userInfoFromId:userId
                                     success:^(NSHTTPURLResponse *response, id responseJSON) {
                                         NSLog(@"!!!!get userInfo succeeded!!!!, %@", responseJSON);
                                         // add to cache
                                         NSString *fullName = [NSString stringWithFormat:@"%@ %@",responseJSON[@"first_name"],responseJSON[@"last_name"]];
                                         NSString *desc = responseJSON[@"description"];
                                         NSNumber *deg1 = responseJSON[@"num_degree1"];
                                         NSNumber *deg2 = responseJSON[@"num_degree2"];
                                         self.userInfoCache[@(userId)] = @{
                                                                           @"full_name" : fullName,
                                                                           @"description" : desc ? desc : @"unknown",
                                                                           @"num_degree1" : deg1 ? deg1 : @(0),
                                                                           @"num_degree2" : deg2 ? deg2 : @(0),
                                                                           };
                                         if (callback) {
                                             callback(self.userInfoCache[@(userId)]);
                                         }
                                     } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
                                         NSLog(@"!!!!!get userInfo failed");
                                     }];
    }
}
- (UIImage *)userPicture:(NSInteger)userId
{
    if (self.userPictureCache[@(userId)]) {
        return self.userPictureCache[@(userId)];
    } else {
        NSURL *url = [[MLApiClient client] userPictureUrl:userId];
        if (url) {
            NSData *imageData = [NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:imageData];
            if (image) {
                self.userPictureCache[@(userId)] = image;
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
        self.userInfoCache = [[NSMutableDictionary alloc] init];
        self.userPictureCache = [[NSMutableDictionary alloc] init];
    }
    return self;
}
@end
