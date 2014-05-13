//
//  PostFeedTableViewController.m
//  test1
//
//  Created by Tim Cheng on 5/12/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "PostFeedTableViewController.h"
#import "MLApiClient.h"
#import "MLPostInfo.h"
#import "MLUserInfo.h"
#import "NSDate+TimeAgo.h"

#define kFeedPostTextViewHeight 228.0f

@interface PostFeedTableViewController () <UITableViewDataSource, UITextViewDelegate, UITextViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) NSMutableArray *postArray;
@property (strong, nonatomic) NSDateFormatter *myFormatter;
@property (assign, nonatomic) NSInteger commentPostId;


@end

@implementation PostFeedTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.myFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [self.myFormatter setLocale:enUSPOSIXLocale];
    [self.myFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSSSS'Z'"];
    [self.myFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"US/Eastern"]];

    self.postArray = [[NSMutableArray alloc] initWithCapacity:100];
    self.tableView.dataSource = self;

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 180.0f, 0);

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self action:@selector(loadPosts) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    [self loadPostsAndScroll:NO];
}

- (void)loadPosts
{
    [self loadPostsAndScroll:NO];
    [self.refreshControl endRefreshing];
}

- (void)loadPostsAndScroll:(BOOL)needScroll
{
    [[MLPostInfo instance] loadPostInfoFromId:[MLApiClient client].userId
                                       degree:1
                                      success:^(id responseJSON) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              
                                              [self.tableView beginUpdates];
                                              NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
                                              if ([self.postArray count] > 0) {
                                                  for (int i=0; i<[self.postArray count]; i++) {
                                                      [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                                                  }
                                                  [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                                                  [self.postArray removeAllObjects];
                                                  [indexPaths removeAllObjects];
                                              }
                                              
                                              [self.postArray addObjectsFromArray:responseJSON];
                                              for (int i=0; i<[self.postArray count]; i++) {
                                                  [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                                              }
                                              [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                                              
                                              [self.tableView endUpdates];
                                              if (needScroll) {
                                                  // scroll to top
                                                  [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                                              }
                                          });
                                      }];
}

- (void)toggleComment:(NSInteger)postId cell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (self.commentPostId == 0) {
        self.commentPostId = postId;
        if (self.delegate) {
            [self.delegate postFeed:self willOpenComment:postId atIndexPath:indexPath];
        }
    } else {
        self.commentPostId = 0;
        if (self.delegate) {
            [self.delegate postFeed:self willCloseComment:postId];
        }
    }
}


- (void)tapOnComment:(UITapGestureRecognizer *)gest
{
    UIImageView *img = (UIImageView*)gest.view;
    NSInteger postId = [img superview].tag - 1000;
    UITableViewCell *cell = (UITableViewCell*)[[[img superview] superview] superview];
    [self toggleComment:postId cell:cell];
}

- (void)tapOnStar:(UITapGestureRecognizer *)gest
{
    UIImageView *img = (UIImageView*)gest.view;
    NSInteger postId = [img superview].tag - 1000;
    
    BOOL enable = img.highlighted ? NO : YES;
    
    NSLog(@"tap on star: %d", enable);
    [[MLApiClient client] setStarFromId: kApiClientUserSelf
                                 postId:postId
                                 enable:enable
                                success:^(NSHTTPURLResponse *response, id responseJSON) {
                                    NSLog(@"!!!!! add star succeeded!!!!! ");
                                    [self loadPostsAndScroll:NO];
                                } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
                                    NSLog(@"!!!!! add star failed !!!!!! ");
                                }];
}

- (void)tapOnMore:(UITapGestureRecognizer *)gest
{
    NSLog(@"tap... ");
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Share on Facebook", @"Delete Post", nil];
    UIImageView *img = (UIImageView*)gest.view;
    NSInteger postId = [img superview].tag - 1000;
    popup.tag = postId;
    //[popup showInView:self.tableView];
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"count = %d", [self.postArray count]);
    return [self.postArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MainFeedCell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSLog(@"cell view here... I am here...");
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // TODO: save post_id tag
    NSInteger postId = [self.postArray[indexPath.row][@"id"] integerValue];
    cell.contentView.tag = postId + 1000;
    
    // set post text
    UIImageView *userImage = (UIImageView *)[cell.contentView viewWithTag:20];
    userImage.image = [[MLUserInfo instance] userPicture:[self.postArray[indexPath.row][@"user_id"] integerValue]];
    userImage.layer.borderWidth = 1.0f;
    userImage.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    userImage.layer.cornerRadius = 20;
    userImage.clipsToBounds = YES;
    
    // add background
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:30];
    if (imageView) {
        [imageView removeFromSuperview];
    }
    if ([self.postArray[indexPath.row][@"has_picture"] boolValue]) {
        // has picture
        [[MLPostInfo instance] postPicture:postId success:^(UIImage *responseImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // if the cell is still for the post
                if (cell.contentView.tag == postId + 1000 ) {
                    UIImageView *imageView = [[UIImageView alloc] initWithImage:responseImage];
                    imageView.tag = 30;
                    [cell.contentView addSubview:imageView ];
                    [cell.contentView sendSubviewToBack:imageView ];
                }
            });
        }];
    }
    
    UITextView *postTextView = (UITextView *)[cell.contentView viewWithTag:10];
    if (postTextView) {
        postTextView.text = self.postArray[indexPath.row][@"body"];
        postTextView.delegate = self;
        float height = [postTextView sizeThatFits:postTextView.frame.size].height;
        postTextView.contentInset = UIEdgeInsetsMake((kFeedPostTextViewHeight-height)/2, 0, 0, 0);
    }
    
    // set post background color
    NSString *bgColor = self.postArray[indexPath.row][@"bg_color"];
    if (bgColor) {
        cell.contentView.backgroundColor = [self stringToColor:bgColor];
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
    if (nComments) {
        nComments.text = [self.postArray[indexPath.row][@"num_comments"] stringValue];
    }
    UILabel *nStars = (UILabel *)[cell.contentView viewWithTag:13];
    if (nStars) {
        nStars.text = [self.postArray[indexPath.row][@"num_stars"] stringValue];
    }
    
    UIImageView *comment = (UIImageView *)[cell.contentView viewWithTag:16];
    if (comment) {
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self
                                             action:@selector(tapOnComment:)];
        [singleTap setNumberOfTapsRequired:1];
        comment.userInteractionEnabled = YES;
        [comment addGestureRecognizer:singleTap];
        if ([self.postArray[indexPath.row][@"num_comments"] integerValue] > 0) {
            comment.highlighted = YES;
        }
    }
    
    UIImageView *star = (UIImageView *)[cell.contentView viewWithTag:17];
    if (star) {
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self
                                             action:@selector(tapOnStar:)];
        [singleTap setNumberOfTapsRequired:1];
        star.userInteractionEnabled = YES;
        [star addGestureRecognizer:singleTap];
        if ([self.postArray[indexPath.row][@"self_star"] integerValue] > 0) {
            star.highlighted = YES;
        }
    }
    
    // set user name / description
    NSInteger userId = [self.postArray[indexPath.row][@"user_id"] integerValue];
    [[MLUserInfo instance] userInfoFromId:userId
                                  success:^(id responseJSON) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          UILabel *posterName = (UILabel *)[cell.contentView viewWithTag:14];
                                          posterName.text = responseJSON[@"full_name"];
                                          UILabel *posterDesc = (UILabel *)[cell.contentView viewWithTag:15];
                                          posterDesc.text = responseJSON[@"description"];
                                      });
                                  }];

    // only show more button to post owner
    UIImageView *more = (UIImageView *)[cell.contentView viewWithTag:19];
    if (userId != [MLApiClient client].userId) {
        more.hidden = YES;
    } else {
        if (more) {
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(tapOnMore:)];
            [singleTap setNumberOfTapsRequired:1];
            more.userInteractionEnabled = YES;
            [more addGestureRecognizer:singleTap];
        }
    }
    
    return cell;
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    NSLog(@"I am here... ");
    NSInteger postId = [textView superview].tag - 1000;
    UITableViewCell *cell = (UITableViewCell*)[[[textView superview] superview] superview];
    [self toggleComment:postId cell:cell];
    return NO;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"index = %d", buttonIndex);
    switch (buttonIndex) {
        case 0:
            NSLog(@"share on facebook");
            break;
        case 1:
        {
            // delete post
            [[MLPostInfo instance] deletePostId:popup.tag success:^(id responseJSON) {
                if (self.commentPostId == 0) {
                    [self loadPosts];
                } else {
                    self.commentPostId = 0;
                    if (self.delegate) {
                        [self.delegate postFeed:self willCloseComment:popup.tag];
                    }
                }
            }];
            break;
        }
        default:
            break;
    }
}

#pragma mark - helper

-(UIColor *)stringToColor:(NSString *)s
{
    int r,g,b,a;
    sscanf([s UTF8String], "%02x%02x%02x%02x", &r, &g, &b, &a);
    CGFloat rf = (CGFloat)r / 255.0f;
    CGFloat gf = (CGFloat)g / 255.0f;
    CGFloat bf = (CGFloat)b / 255.0f;
    CGFloat af = (CGFloat)a / 255.0f;
    return [UIColor colorWithRed:rf green:gf blue:bf alpha:af];
}

@end
