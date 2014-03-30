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
@property (strong, nonatomic) Firebase *firebase;
@property (strong, nonatomic) FirebaseSimpleLogin *firebaseAuth;
@property (strong, nonatomic) NSString *loggedInUserId;

@end
