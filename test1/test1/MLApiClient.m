//
//  MLApiClient.m
//  test1
//
//  Created by Tim Cheng on 5/3/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "MLApiClient.h"

@interface MLApiClient ()

@property (strong, nonatomic) NSString *protocol;
@property (strong, nonatomic) NSString *baseURLString;
@property (strong, nonatomic) NSOperationQueue *requestQueue;

@property (strong, nonatomic) NSString *loggedInAuth;
@property (assign, nonatomic) NSInteger loggedInUserId;

@end

@implementation MLApiClient

+ (MLApiClient *)client
{
    static MLApiClient *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MLApiClient alloc] init];
    });
    return sharedInstance;
}


- (id)init
{
    return [self initWithProtocol:@"http" baseURLString:@"localhost:8080"];
}

- (id)initWithProtocol:(NSString *)protocol baseURLString:(NSString *)baseURLString
{
    self = [super init];
    if (self) {
        self.protocol = protocol;
        self.baseURLString = baseURLString;
        self.requestQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

static NSString * AFBase64EncodedStringFromString(NSString *string) {
    NSData *data = [NSData dataWithBytes:[string UTF8String] length:[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    NSUInteger length = [data length];
    NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    
    uint8_t *input = (uint8_t *)[data bytes];
    uint8_t *output = (uint8_t *)[mutableData mutableBytes];
    
    for (NSUInteger i = 0; i < length; i += 3) {
        NSUInteger value = 0;
        for (NSUInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        
        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
        output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
}

- (NSString *)authStringEmail:(NSString *)email
                     password:(NSString *)password
{
    NSString *basicAuthCredentials = [NSString stringWithFormat:@"%@:%@", email, password];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", AFBase64EncodedStringFromString(basicAuthCredentials)];
    return authValue;
}

- (NSURLRequest *)loginWithEmail:(NSString *)email
                        password:(NSString *)password
                         success:(MLApiClientSuccess)successCallback
                         failure:(MLApiClientFailure)failureCallback
{
    NSString * path = @"/login";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@%@", self.protocol, self.baseURLString, path]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:15.0f];
    request.HTTPMethod = @"GET";
    [request setValue:[self authStringEmail:email password:password] forHTTPHeaderField:@"Authorization"];
    
    return [self makeRequest:request success:successCallback failure:failureCallback];
}

- (NSURLRequest *)makeRequest:(NSURLRequest *)request
                      success:(MLApiClientSuccess)success
                      failure:(MLApiClientFailure)failure
{
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:self.requestQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error != nil) {
                                   NSLog(@"Error sending request: %@\nerror: %@", request, error);
                               }
                               
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                               NSUInteger code = httpResponse.statusCode;
                               
                               NSError *parseError;
                               id JSON = nil;
                               if (data != nil) {
                                   JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];
                                   if (parseError && data.length > 1) {
                                       NSLog(@"Parse error: %@", parseError);
                                       NSLog(@"Error parsing JSON for request.");
                                       
                                       if (failure) {
                                           failure(httpResponse, @{}, parseError);
                                       }
                                       return;
                                   }
                               } else if (NSURLErrorDomain == [error domain] && NSURLErrorTimedOut == [error code]) {
                                   code = 408; //request timeout
                               } else {
                                   JSON = @{};
                               }
                               
                               if (code >= 200 && code <= 299 && success) {
                                   success(httpResponse, JSON);
                               } else if (code > 399 && failure) {
                                   failure(httpResponse, JSON, error);
                               }
                           }];
    return request;
}

- (void) setLoggedInInfoWithEamil:(NSString *)email
                         password:(NSString *)password
                           userId:(NSInteger)userId
{
    NSLog(@"set logged in user info...");
    self.loggedInAuth = [self authStringEmail:email password:password];
    self.loggedInUserId = userId;
}

- (NSURLRequest *)userInfoFromId:(NSInteger)userId
                         success:(MLApiClientSuccess)successCallback
                         failure:(MLApiClientFailure)failureCallback
{
    NSInteger uid = (userId < 0) ? self.loggedInUserId : userId;
    NSString * path = @"/users";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@%@/%d", self.protocol, self.baseURLString, path, uid]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:15.0f];
    request.HTTPMethod = @"GET";
    [request setValue:self.loggedInAuth forHTTPHeaderField:@"Authorization"];
    return [self makeRequest:request success:successCallback failure:failureCallback];
}

- (NSURLRequest *)postsFromId:(NSInteger)userId
                       degree:(NSInteger)degree
                      success:(MLApiClientSuccess)successCallback
                      failure:(MLApiClientFailure)failureCallback
{
    NSInteger uid = (userId < 0) ? self.loggedInUserId : userId;
    NSString * path = @"/posts";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@%@?user_id=%d&degree=%d", self.protocol, self.baseURLString, path, uid, degree]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:15.0f];
    request.HTTPMethod = @"GET";
    [request setValue:self.loggedInAuth forHTTPHeaderField:@"Authorization"];
    return [self makeRequest:request success:successCallback failure:failureCallback];
}

- (NSURLRequest *)sendPostFromId:(NSInteger)userId
                            body:(NSString *)body
                         success:(MLApiClientSuccess)successCallback
                         failure:(MLApiClientFailure)failureCallback
{
    NSInteger uid = (userId < 0) ? self.loggedInUserId : userId;
    NSString * path = @"/posts";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@%@", self.protocol, self.baseURLString, path]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:15.0f];
    
    NSString *params = [NSString stringWithFormat:@"user_id=%d&body=%@", uid, [self urlEncode:body]];
    NSData *postData = [params dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    request.HTTPMethod = @"POST";
    [request setValue:self.loggedInAuth forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
    request.HTTPBody = postData;
    return [self makeRequest:request success:successCallback failure:failureCallback];
}



- (NSInteger)userId
{
    return self.loggedInUserId;
}


- (NSString *)urlEncode:(NSString *)param
{
    return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (__bridge CFStringRef)param,
                                                              NULL,
                                                              CFSTR("!*'();:@&=+$,/?%#[]"),
                                                              kCFStringEncodingUTF8));
}

@end
