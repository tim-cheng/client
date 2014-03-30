//
//  DBClient.m
//  test1
//
//  Created by Tim Cheng on 3/29/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "DBClient.h"

@interface DBClient ()



@end


@implementation DBClient

+ (DBClient *)client
{
    static DBClient *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DBClient alloc] init];
    });
    return sharedInstance;
}

+ (NSString *)baseURL
{
    return @"https://monitortest.firebaseIO.com";
}

+ (NSString *)urlForUserId:(NSString *)userId
{
    return [NSString stringWithFormat:@"%@/user/%@", [self baseURL], userId];

}

+ (NSString *)urlForFBUserId:(NSString *)fbId
{
    return [NSString stringWithFormat:@"%@/fbuser/%@", [self baseURL], fbId];
    
}

+ (NSString *)urlForLoggedInUser
{
    return [self urlForUserId:[self client].loggedInUserId];
    
}

+ (Firebase *)refForBase
{
    return [[Firebase alloc] initWithUrl:[self baseURL]];
}

+ (Firebase *)refForUserId:(NSString *)userId
{
    return [[Firebase alloc] initWithUrl:[self urlForUserId:userId]];
}


+ (Firebase *)refForFBUserId:(NSString *)fbId
{
    return [[Firebase alloc] initWithUrl:[self urlForFBUserId:fbId]];
}

- (id)init
{
    self = [super init];
    self.firebase = [[Firebase alloc] initWithUrl:[[self class] baseURL]];
    self.firebaseAuth = [[FirebaseSimpleLogin alloc] initWithRef:self.firebase];
    return self;
}

@end
