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

@interface MainFeedViewController () <UITableViewDataSource, UITextViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSMutableArray *postArray;
@property (strong, nonatomic) NSMutableArray *commentArray;

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UITableView *mainFeedView;
@property (strong, nonatomic) IBOutlet UIView *composeView;
@property (strong, nonatomic) IBOutlet UITextView *postTextView;

@property (strong, nonatomic) IBOutlet UILabel *headerName;
@property (strong, nonatomic) IBOutlet UILabel *headerConnections;

@property (strong, nonatomic) NSDateFormatter *myFormatter;
@property (assign, nonatomic) BOOL isCommentMode;

@property (strong, nonatomic) IBOutlet UITableView *commentFeedView;
@property (strong, nonatomic) IBOutlet UITextField *commentField;
@property (assign, nonatomic) NSInteger commentPostId;

- (IBAction)compose:(id)sender;

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
    self.commentArray = [[NSMutableArray alloc] initWithCapacity:100];

    // load user info
    [[MLUserInfo instance] userInfoFromId:[MLApiClient client].userId
                                  success:^(id responseJSON) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          self.headerName.text = responseJSON[@"full_name"];
                                          self.headerConnections.text = [NSString stringWithFormat:@"%d 1st   %d 2nd", [responseJSON[@"num_degree1"] integerValue], [responseJSON[@"num_degree2"] integerValue]];
                                      });
                                  }];
    
    // prepare composeView
    [self.postTextView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    self.postTextView.delegate = self;
    
    self.commentField.delegate = self;
    
    [self loadPosts];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadPosts
{
    [[MLApiClient client] postsFromId:[MLApiClient client].userId
                               degree:1
                              success:^(NSHTTPURLResponse *response, id responseJSON) {
                                  NSLog(@"!!!!get posts succeeded!!!!, %@", responseJSON);
                                  dispatch_async(dispatch_get_main_queue(), ^{

                                      [self.mainFeedView beginUpdates];
                                      NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
                                      if ([self.postArray count] > 0) {
                                          for (int i=0; i<[self.postArray count]; i++) {
                                              [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                                          }
                                          [self.mainFeedView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                                          [self.postArray removeAllObjects];
                                          [indexPaths removeAllObjects];
                                      }
                                      
                                      [self.postArray addObjectsFromArray:responseJSON];
                                      for (int i=0; i<[self.postArray count]; i++) {
                                          [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                                      }
                                      [self.mainFeedView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                                      [self.mainFeedView endUpdates];
                                  });
                              } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
                                  NSLog(@"!!!!!get posts failed");
                              }];
}

- (void)loadCommentsForPostId:(NSInteger)postId
{
    [[MLApiClient client] commentsFromId:postId
                              success:^(NSHTTPURLResponse *response, id responseJSON) {
                                  NSLog(@"!!!!get comments succeeded!!!!, %@", responseJSON);
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [self.commentFeedView beginUpdates];
                                      NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
                                      if ([self.commentArray count] > 0) {
                                          for (int i=0; i<[self.commentArray count]; i++) {
                                              [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                                          }
                                          [self.commentFeedView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                                          [self.commentArray removeAllObjects];
                                          [indexPaths removeAllObjects];
                                      }
                                      
                                      [self.commentArray addObjectsFromArray:responseJSON];
                                      for (int i=0; i<[self.commentArray count]; i++) {
                                          [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                                      }
                                      [self.commentFeedView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                                      [self.commentFeedView endUpdates];
                                  });
                              } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
                                  NSLog(@"!!!!!get comments failed");
                              }];
}


#pragma mark UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.mainFeedView) {
        return [self.postArray count];
    } else {
        return [self.commentArray count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.mainFeedView) {
        static NSString *cellIdentifier = @"MainFeedCell";
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        
        // TODO: save post_id tag
        cell.contentView.tag = [self.postArray[indexPath.row][@"id"] integerValue] + 1000;
        
        // set post text
        UITextView *postTextView = (UITextView *)[cell.contentView viewWithTag:10];
        if (postTextView) {
            postTextView.text = self.postArray[indexPath.row][@"body"];
            [postTextView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
            postTextView.delegate = self;
        }
        
        // set time ago
        NSString *timeString = self.postArray[indexPath.row][@"created_at"];
        NSString *displayTime = @"long ago";
        if (timeString) {
            NSDate *time = [self.myFormatter dateFromString:timeString];
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
        
    } else {
        // comment view
        static NSString *cellIdentifier = @"CommentCell";
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        // set comment body
        UILabel *comment = (UILabel *)[cell.contentView viewWithTag:11];
        comment.text = self.commentArray[indexPath.row][@"body"];
        // set time ago
        NSString *timeString = self.commentArray[indexPath.row][@"created_at"];
        NSString *displayTime = @"long ago";
        if (timeString) {
            NSDate *time = [self.myFormatter dateFromString:timeString];
            displayTime = [time timeAgo];
        }
        UILabel *time = (UILabel *)[cell.contentView viewWithTag:12];
        time.text = displayTime;
        return cell;
    }
}

#pragma mark UITextFieldDelgate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"should return........");
    [textField resignFirstResponder];
    // post comments
    [[MLApiClient client] sendCommentFromId:[MLApiClient client].userId
                                     postId:self.commentPostId
                                       body:textField.text
                                    success:^(NSHTTPURLResponse *response, id responseJSON) {
                                        NSLog(@"!!!!post comment succeeded");
                                        self.commentField.text = @"";
                                        if (self.commentPostId) {
                                            [self loadCommentsForPostId:self.commentPostId];
                                        }
                                    } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
                                        NSLog(@"!!!!post comment failed");
                                    }];
    
    return YES;
}

#pragma mark UITextViewDelgate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (textView == self.postTextView) {
        textView.text = @"";
        return YES;
    } else {
        // find current indexPath
        NSIndexPath *indexPath = [self.mainFeedView indexPathForCell:(UITableViewCell*)[[[textView superview] superview] superview]];
        NSLog(@"indexPath.row =%@, %d, %d", indexPath, indexPath.row, self.commentPostId);
        // compose
        NSLog(@"!!!!!tapped...");
        
        self.isCommentMode = !self.isCommentMode;
        if (self.isCommentMode) {
            self.commentPostId = [textView superview].tag - 1000;
            [UIApplication sharedApplication].statusBarHidden = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.headerView.hidden = YES;
                CGRect newFrame = self.mainFeedView.frame;
                newFrame.origin.y = 0;
                newFrame.size.height = 272;
                self.mainFeedView.frame = newFrame;
                [self.mainFeedView scrollToRowAtIndexPath:indexPath
                                     atScrollPosition:UITableViewScrollPositionTop
                                             animated:NO];
                self.mainFeedView.scrollEnabled = NO;
                self.commentFeedView.hidden = NO;
                self.commentFeedView.dataSource = self;
                [self loadCommentsForPostId:self.commentPostId];
                [self.commentFeedView reloadData];
            });
        } else {
            self.commentPostId = 0;
            [UIApplication sharedApplication].statusBarHidden = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.headerView.hidden = NO;
                CGRect newFrame = self.mainFeedView.frame;
                newFrame.origin.y = 68;
                newFrame.size.height = 520;
                self.mainFeedView.frame = newFrame;
                self.mainFeedView.scrollEnabled = YES;
                self.commentFeedView.hidden = YES;
                self.commentFeedView.dataSource = nil;
                [self.commentField resignFirstResponder];
            });
        }
        
        
        return NO;
    }
}

#pragma mark - IBAction
- (IBAction)compose:(id)sender
{
    self.composeView.hidden = !self.composeView.hidden;
    if (!self.composeView.hidden) {
        // composing
    } else {
        [self.postTextView resignFirstResponder];
        [[MLApiClient client] sendPostFromId:kApiClientUserSelf
                                        body:self.postTextView.text
                                     success:^(NSHTTPURLResponse *response, id responseJSON) {
                                         NSLog(@"!!!!! post succeeded!!!!! ");
                                         [self loadPosts];
                                         
                                     } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
                                         NSLog(@"!!!!! post failed !!!!!! ");
                                     }];
    }
    
}

// http://stackoverflow.com/questions/22013768/center-the-text-in-a-uitextview-vertical-and-horizontal-align
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UITextView *txtview = object;
    CGFloat topoffset = ([txtview bounds].size.height - [txtview contentSize].height * [txtview zoomScale])/2.0;
    topoffset = ( topoffset < 0.0 ? 0.0 : topoffset );
    txtview.contentOffset = (CGPoint){.x = 0, .y = -topoffset};
}


@end
