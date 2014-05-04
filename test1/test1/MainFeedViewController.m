//
//  MainFeedViewController.m
//  test1
//
//  Created by Tim Cheng on 4/27/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "MainFeedViewController.h"
#import "MLApiClient.h"
#import "MLUserInfo.h"
#import "NSDate+TimeAgo.h"

@interface MainFeedViewController () <UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *postArray;

@property (strong, nonatomic) IBOutlet UITableView *mainFeedView;

@property (strong, nonatomic) IBOutlet UILabel *headerName;
@property (strong, nonatomic) IBOutlet UILabel *headerConnections;

@property (strong, nonatomic) NSDateFormatter *myFormatter;

@end

@implementation MainFeedViewController

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
    self.myFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [self.myFormatter setLocale:enUSPOSIXLocale];
    [self.myFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSSSS'Z'"];
    [self.myFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"US/Pacific"]];

    self.postArray = [[NSMutableArray alloc] initWithCapacity:100];
    self.mainFeedView.dataSource = self;

    // load user info
    [[MLUserInfo instance] userInfoFromId:[MLApiClient client].userId
                                  success:^(id responseJSON) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          self.headerName.text = responseJSON[@"full_name"];
                                          self.headerConnections.text = [NSString stringWithFormat:@"%d 1st   %d 2nd", [responseJSON[@"num_degree1"] integerValue], [responseJSON[@"num_degree2"] integerValue]];
                                      });
                                  }];
    
    // load posts
    [[MLApiClient client] postsFromId:-1
                               degree:1
                              success:^(NSHTTPURLResponse *response, id responseJSON) {
                                  NSLog(@"!!!!get posts succeeded!!!!, %@", responseJSON);
                                  [self.postArray addObjectsFromArray:responseJSON];
                                  NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
                                  for (int i=0; i<[self.postArray count]; i++) {
                                      [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                                  }
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [self.mainFeedView beginUpdates];
                                      [self.mainFeedView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                                      [self.mainFeedView endUpdates];
                                  });
                              } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
                                  NSLog(@"!!!!!get posts failed");
                              }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.postArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MainFeedCell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
//    cell.backgroundColor = [UIColor redColor];
//    UITextView *textView = (UITextView *)[cell.contentView viewWithTag:10];
//    textView.backgroundColor = [UIColor clearColor];

    // set post text
    UITextView *postTextView = (UITextView *)[cell.contentView viewWithTag:10];
    if (postTextView) {
        postTextView.text = self.postArray[indexPath.row][@"body"];
    }
    
    // set time ago
    NSString *timeString = self.postArray[indexPath.row][@"created_at"];
//    NSString *timeString = @"2014-05-04T09:50:24Z";
    NSString *displayTime = @"long ago";
    if (timeString) {
        NSDate *time = [self.myFormatter dateFromString:timeString];
        NSLog(@"%@ time is %@", timeString, time);
        displayTime = [time timeAgo];
    }
    UILabel *time = (UILabel *)[cell.contentView viewWithTag:11];
    time.text = displayTime;
    
    // set comments/stars
    UILabel *nComments = (UILabel *)[cell.contentView viewWithTag:12];
    nComments.text = [self.postArray[indexPath.row][@"num_comments"] stringValue];
    UILabel *nStars = (UILabel *)[cell.contentView viewWithTag:13];
    nStars.text = [self.postArray[indexPath.row][@"num_stars"] stringValue];
    
    // set user name / description
    [[MLUserInfo instance] userInfoFromId:([self.postArray[indexPath.row][@"user_id"] integerValue])
                                  success:^(id responseJSON) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UILabel *posterName = (UILabel *)[cell.contentView viewWithTag:14];
            posterName.text = responseJSON[@"full_name"];
            UILabel *posterDesc = (UILabel *)[cell.contentView viewWithTag:15];
            posterDesc.text = responseJSON[@"description"];
        });
    }];

    return cell;
}


@end
