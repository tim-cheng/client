//
//  MLApiClient.h
//  test1
//
//  Created by Tim Cheng on 5/3/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

typedef void (^MLApiClientSuccess)(NSHTTPURLResponse *response, id responseJSON);
typedef void (^MLApiClientFailure)(NSHTTPURLResponse *response, id responseJSON, NSError *error);

#import <Foundation/Foundation.h>

@interface MLApiClient : NSObject


+ (MLApiClient *)client;

- (NSURLRequest *)loginWithEmail:(NSString *)email
                        password:(NSString *)password
                         success:(MLApiClientSuccess)successCallback
                         failure:(MLApiClientFailure)failureCallback;

- (void) setLoggedInInfoWithEamil:(NSString *)email
                         password:(NSString *)password
                           userId:(NSInteger)userId;


- (NSURLRequest *)userInfoFromId:(NSInteger)userId
                         success:(MLApiClientSuccess)successCallback
                         failure:(MLApiClientFailure)failureCallback;

- (NSURLRequest *)postsFromId:(NSInteger)userId
                      success:(MLApiClientSuccess)successCallback
                      failure:(MLApiClientFailure)failureCallback;

@end