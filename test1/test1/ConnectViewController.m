//
//  ConnectViewController.m
//  test1
//
//  Created by Tim Cheng on 3/28/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "ConnectViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "DBClient.h"

@interface ConnectViewController ()

- (IBAction) connectFacebook:(id)sender;

@end

@implementation ConnectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addFriendWithId:(NSString *)userId
{
    NSLog(@"found and add friend: %@", userId);
    NSString *baseLoc = [NSString stringWithFormat:@"%@/friend/%@", [DBClient urlForLoggedInUser], userId];
    Firebase *friendRef = [[Firebase alloc] initWithUrl:baseLoc];
    [friendRef setValue: @{@"src" : @"fb"}];
    
    baseLoc = [NSString stringWithFormat:@"%@/following/%@", userId, [DBClient urlForLoggedInUser]];
    friendRef = [[Firebase alloc] initWithUrl:baseLoc];
    [friendRef setValue: @{@"src" : @"fb"}];
}

- (IBAction) connectFacebook:(id)sender
{
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        NSArray* friends = [result objectForKey:@"data"];
        //NSLog(@"Found: %i friends", friends.count);
        for (NSDictionary<FBGraphUser>* friend in friends) {
            //NSLog(@"I have a friend named %@", friend);
            Firebase *ref = [DBClient refForFBUserId:friend.id];
            [ref observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                if ([snapshot.value isKindOfClass:[NSDictionary class]]) {
                    NSString *userId = snapshot.value[@"id"];
                    if (userId) {
                        // fb user exist in system, add to friend list
                        [self addFriendWithId:userId];
                    }
                }
            }];
        }
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
