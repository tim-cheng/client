//
//  MLApiClient.h
//  test1
//
//  Created by Tim Cheng on 5/3/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

typedef void (^MLApiClientSuccess)(NSHTTPURLResponse *response, id responseJSON);
typedef void (^MLApiClientFailure)(NSHTTPURLResponse *response, id responseJSON, NSError *error);
typedef void (^MLApiClientDataSuccess)(NSHTTPURLResponse *response, NSData *data);

#define kApiClientUserSelf -1

#import <Foundation/Foundation.h>


@interface MLApiClient : NSObject

@property (readonly, nonatomic) NSInteger userId;

+ (MLApiClient *)client;

- (NSURL *)userPictureUrl:(NSInteger)userId;
- (NSURL *)postPictureUrl:(NSInteger)postId;

- (NSURLRequest *)loginWithEmail:(NSString *)email
                        password:(NSString *)password
                         success:(MLApiClientSuccess)successCallback
                         failure:(MLApiClientFailure)failureCallback;

- (NSURLRequest *)loginWithFB:(NSString *)email
                  accessToken:(NSString *)accessToken
                    firstName:(NSString *)firstName
                     lastName:(NSString *)lastName
                         fbId:(NSString *)fbId
                      success:(MLApiClientSuccess)successCallback
                      failure:(MLApiClientFailure)failureCallback;

- (NSURLRequest *)createUser:(NSString *)email
                    password:(NSString *)password
                   firstName:(NSString *)firstName
                    lastName:(NSString *)lastName
                     success:(MLApiClientSuccess)successCallback
                     failure:(MLApiClientFailure)failureCallback;

- (void) setLoggedInInfoWithEmail:(NSString *)email
                         password:(NSString *)password
                           userId:(NSInteger)userId;

- (NSURLRequest *)userInfoFromId:(NSInteger)userId
                         success:(MLApiClientSuccess)successCallback
                         failure:(MLApiClientFailure)failureCallback;

- (NSURLRequest *)postsFromId:(NSInteger)userId
                       degree:(NSInteger)degree
                      success:(MLApiClientSuccess)successCallback
                      failure:(MLApiClientFailure)failureCallback;

- (NSURLRequest *)commentsFromId:(NSInteger)userId
                         success:(MLApiClientSuccess)successCallback
                         failure:(MLApiClientFailure)failureCallback;

- (NSURLRequest *)sendPostFromId:(NSInteger)userId
                            body:(NSString *)body
                         bgColor:(UIColor *)bgColor
                         success:(MLApiClientSuccess)successCallback
                         failure:(MLApiClientFailure)failureCallback;

- (NSURLRequest *)postPictureFromeId:(NSInteger)postId
                             success:(MLApiClientDataSuccess)successCallback
                             failure:(MLApiClientFailure)failureCallback;

- (NSURLRequest *)sendPostPictureId:(NSInteger)postId
                              image:(UIImage *)image
                            success:(MLApiClientSuccess)successCallback
                            failure:(MLApiClientFailure)failureCallback;

- (NSURLRequest *)sendCommentFromId:(NSInteger)userId
                             postId:(NSInteger)postId
                               body:(NSString *)body
                            success:(MLApiClientSuccess)successCallback
                            failure:(MLApiClientFailure)failureCallback;

- (NSURLRequest *)setStarFromId:(NSInteger)userId
                         postId:(NSInteger)postId
                         enable:(BOOL)enable
                        success:(MLApiClientSuccess)successCallback
                        failure:(MLApiClientFailure)failureCallback;

- (NSURLRequest *)deletePostId:(NSInteger)postId
                       success:(MLApiClientSuccess)successCallback
                       failure:(MLApiClientFailure)failureCallback;

- (NSURLRequest *)findUser:(NSString *)name
                   success:(MLApiClientSuccess)successCallback
                   failure:(MLApiClientFailure)failureCallback;

- (NSURLRequest *)inviteUserFromId:(NSInteger)userId
                          inviteId:(NSInteger)inviteId
                           success:(MLApiClientSuccess)successCallback
                           failure:(MLApiClientFailure)failureCallback;

- (NSURLRequest *)invitesForId:(NSInteger)userId
                       success:(MLApiClientSuccess)successCallback
                       failure:(MLApiClientFailure)failureCallback;

- (NSURLRequest *)connectionsForId:(NSInteger)userId
                           success:(MLApiClientSuccess)successCallback
                           failure:(MLApiClientFailure)failureCallback;

- (NSURLRequest *)activitiesForId:(NSInteger)userId
                          success:(MLApiClientSuccess)successCallback
                          failure:(MLApiClientFailure)failureCallback;

- (NSURLRequest *)kidsForId:(NSInteger)userId
                    success:(MLApiClientSuccess)successCallback
                    failure:(MLApiClientFailure)failureCallback;

- (NSURLRequest *)acceptInviteUserFromId:(NSInteger)userId
                                inviteId:(NSInteger)inviteId
                                 success:(MLApiClientSuccess)successCallback
                                 failure:(MLApiClientFailure)failureCallback;

@end
