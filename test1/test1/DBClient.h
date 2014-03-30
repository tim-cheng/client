//
//  DBClient.h
//  test1
//
//  Created by Tim Cheng on 3/29/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>
#import <FirebaseSimpleLogin/FirebaseSimpleLogin.h>


@interface DBClient : NSObject

+ (DBClient *)client;

+ (NSString *)baseURL;
+ (NSString *)urlForUserId:(NSString *)userId;
+ (NSString *)urlForFBUserId:(NSString *)fbId;
+ (NSString *)urlForLoggedInUser;

+ (Firebase *)refForBase;
+ (Firebase *)refForUserId:(NSString *)userId;
+ (Firebase *)refForFBUserId:(NSString *)fbId;

@property (strong, nonatomic) Firebase *firebase;
@property (strong, nonatomic) FirebaseSimpleLogin *firebaseAuth;
@property (strong, nonatomic) NSString *loggedInUserId;

@end
