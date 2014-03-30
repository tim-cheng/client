//
//  FBClient.m
//  test1
//
//  Created by Tim Cheng on 3/29/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "FBClient.h"

@interface FBClient()
@end

@implementation FBClient

+ (FBClient *)client
{
    static FBClient *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FBClient alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    return self;
}

@end
