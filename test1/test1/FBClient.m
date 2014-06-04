//
//  FBClient.m
//  test1
//
//  Created by Tim Cheng on 3/29/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "FBClient.h"

@interface FBClient()

@property (strong, nonatomic) NSMutableDictionary *dict;

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
    if (self) {
        _dict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

@end
