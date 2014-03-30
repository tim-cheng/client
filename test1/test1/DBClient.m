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

- (id)init
{
    self = [super init];
    self.firebase = [[Firebase alloc] initWithUrl:@"https://monitortest.firebaseIO.com/"];
    self.firebaseAuth = [[FirebaseSimpleLogin alloc] initWithRef:self.firebase];
    return self;
}

@end
