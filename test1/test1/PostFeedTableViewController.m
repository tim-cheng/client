//
//  PostFeedTableViewController.m
//  test1
//
//  Created by Tim Cheng on 5/12/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PostFeedTableViewController.h"
#import "MLApiClient.h"
#import "MLPostInfo.h"
#import "MLUserInfo.h"
#import "NSDate+TimeAgo.h"
#import <FacebookSDK/FacebookSDK.h>
#import "WXApi.h"
#import "MLHelpers.h"

#define kFeedPostTextViewHeight 228.0f

@interface PostFeedTableViewController () <UITableViewDataSource, UITextViewDelegate, UITextViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, CommentFeedDelegate>

@property (strong, nonatomic) NSMutableArray *postArray;
@property (strong, nonatomic) NSDateFormatter *myFormatter;
@property (weak, nonatomic) UITableViewCell *commentPostCell;
@property (assign, nonatomic) NSInteger moreActionPostId;
@property (weak, nonatomic) UITableViewCell *moreActionCell;


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
//    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    refresh.tintColor = MLColorBrown;
    [refresh addTarget:self action:@selector(loadPosts) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    if (self.initUserId == 0) {
        self.initUserId = [MLApiClient client].userId;
        self.initDegree = 2;
    }

    // load saved posts
    if ([self isFeed]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *savedPosts = [defaults objectForKey:@"savedPosts"];
        if (savedPosts) {
            self.postArray = [savedPosts mutableCopy];
            @synchronized(self) {
                [self.tableView beginUpdates];
                [self.tableView endUpdates];
            }
        }
    }
    
    [self loadPostsAndScroll:NO];
}

- (void)loadPosts
{
    [self loadPostsAndScroll:NO];
    [self.refreshControl endRefreshing];
}

- (void)updateTable:(NSMutableArray*)array2
{
    NSMutableArray *array1 = self.postArray;
    int idx1 = 0, idx2=0;
    int cnt1 = [array1 count], cnt2 = [array2 count];
    NSMutableArray *insertPaths = [[NSMutableArray alloc] init];
    NSMutableArray *reloadPaths = [[NSMutableArray alloc] init];
    NSMutableArray *deletePaths = [[NSMutableArray alloc] init];
    while (idx1 < cnt1 && idx2 < cnt2) {
        if ([array2[idx2][@"id"] integerValue] > [array1[idx1][@"id"] integerValue]) {
            // new element, insert
            [insertPaths addObject:[NSIndexPath indexPathForRow:idx2 inSection:0]];
            idx2++;
        } else if ([array2[idx2][@"id"] integerValue] == [array1[idx1][@"id"] integerValue]) {
            // same element
            if (![array1[idx1] isEqualToDictionary:array2[idx2]]) {
                [reloadPaths addObject:[NSIndexPath indexPathForRow:idx2 inSection:0]];
            }
            idx1++;
            idx2++;
        } else {
            // old element need to be deleted
            [deletePaths addObject:[NSIndexPath indexPathForRow:idx1 inSection:0]];
            idx1++;
        }
    }
    if (idx1 < cnt1) {
        for (int i=idx1; i<cnt1; i++) {
            [deletePaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
    }
    if (idx2 < cnt2) {
        for (int i=idx2; i<cnt2; i++) {
            [insertPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
    }
    @synchronized(self) {
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:deletePaths withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView insertRowsAtIndexPaths:insertPaths withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView reloadRowsAtIndexPaths:reloadPaths withRowAnimation:UITableViewRowAnimationNone];
        [self.postArray removeAllObjects];
        [self.postArray addObjectsFromArray:array2];
        [self.tableView endUpdates];
    }
}

- (BOOL)isFeed
{
    return self.initUserId == [MLApiClient client].userId && self.initDegree == 2;
}

- (void)loadPostsAndScroll:(BOOL)needScroll
{
    [[MLPostInfo instance] loadPostInfoFromId:self.initUserId
                                       degree:self.initDegree
                                      success:^(id responseJSON) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [self updateTable:responseJSON];
                                              if ([self isFeed]) {
                                                  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                  [defaults setObject:responseJSON forKey:@"savedPosts"];
                                                  [defaults synchronize];
                                                  if (self.initPostId) {
                                                      [self openPost:self.initPostId];
                                                      self.initPostId = 0;
                                                  } else if (needScroll) {
                                                      // scroll to top
                                                      [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                                                  }
                                              }
                                          });
                                      }];
}

- (void)openPost:(NSInteger)postId
{
    for (int i=0; i<[self.postArray count]; i++) {
        if ([self.postArray[i][@"id"] integerValue] == postId) {
            // found the post, find the indexPath
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath
                                  atScrollPosition:UITableViewScrollPositionTop
                                          animated:NO];
        }
    }
}


- (void)toggleComment:(NSInteger)postId cell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (self.commentPostCell ==nil) {
        self.commentPostCell = cell;
        if (self.delegate) {
            [self.delegate postFeed:self willOpenComment:postId atIndexPath:indexPath];
        }
    } else {
        self.commentPostCell = nil;
        if (self.delegate) {
            [self.delegate postFeed:self willCloseComment:postId];
        }
    }
}


- (void)tapOnComment:(UITapGestureRecognizer *)gest
{
    UIImageView *img = (UIImageView*)gest.view;
    NSInteger postId = [self tagToPostId:[img superview].tag];
    UITableViewCell *cell = (UITableViewCell*)[[[img superview] superview] superview];
    [self toggleComment:postId cell:cell];
}

- (void)tapOnStar:(UITapGestureRecognizer *)gest
{
    UIImageView *img = (UIImageView*)gest.view;
    NSInteger postId = [self tagToPostId:[img superview].tag];
    
    BOOL enable = img.highlighted ? NO : YES;
    
    img.highlighted = enable;
    UILabel *cntLabel = (UILabel *)[[img superview] viewWithTag:13];
    NSInteger cnt = [cntLabel.text integerValue];
    cntLabel.text = [NSString stringWithFormat:@"%d", cnt+(enable ? 1 : -1)];
    
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

- (void)tapOnMore:(UIButton *)button
{
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Share on Facebook", @"Share on WeChat", @"Delete Post", nil];
    NSInteger postId = [self tagToPostId:[button superview].tag];
    self.moreActionPostId = postId;
    self.moreActionCell = (UITableViewCell *)[[button superview] superview];
    //[popup showInView:self.tableView];
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)tapOnProfile:(UITapGestureRecognizer *)gest
{
    UIImageView *img = (UIImageView*)gest.view;
    NSInteger userId = [self tagToUserId:[[img superview] superview].tag];

    NSLog(@"tapped on profile: %d", userId);
    if (self.delegate) {
        [self.delegate postFeed:self willOpenProfile:userId];
    }
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
    UIView *headerView = (UIView *)[cell.contentView viewWithTag:40];
    headerView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
    
    UIImageView *userImage = (UIImageView *)[headerView viewWithTag:20];
    userImage.image = [[MLUserInfo instance] userPicture:[self.postArray[indexPath.row][@"user_id"] integerValue]];
    userImage.layer.borderWidth = 1.0f;
    userImage.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    userImage.layer.cornerRadius = 18;
    userImage.clipsToBounds = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self
                                         action:@selector(tapOnProfile:)];
    [singleTap setNumberOfTapsRequired:1];
    userImage.userInteractionEnabled = YES;
    [userImage addGestureRecognizer:singleTap];

    
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
    UILabel *time = (UILabel *)[headerView viewWithTag:11];
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
                                          UILabel *posterName = (UILabel *)[headerView viewWithTag:14];
                                          posterName.text = responseJSON[@"full_name"];
                                          UILabel *posterDesc = (UILabel *)[headerView viewWithTag:15];
                                          NSString *desc = responseJSON[@"description"];
                                          if (desc) {
                                              desc = [desc stringByReplacingOccurrencesOfString:@" boy" withString:@"\U0001f466"];
                                              desc = [desc stringByReplacingOccurrencesOfString:@" girl" withString:@"\U0001f467"];
                                              desc = [desc stringByReplacingOccurrencesOfString:@", " withString:@"     "];
                                              posterDesc.text = desc;
                                          }
                                      });
                                  }];
    

    NSInteger refId = [self.postArray[indexPath.row][@"ref_user_id"] integerValue];
    UILabel *refName = (UILabel *)[headerView viewWithTag:18];
    if ([self isFeed] && refId != [MLApiClient client].userId) {
        [[MLUserInfo instance] userInfoFromId:refId
                                      success:^(id responseJSON) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              refName.text = [NSString stringWithFormat:@"via %@", responseJSON[@"full_name"]];
                                          });
                                      }];
    } else {
        refName.text = @"";
    }
    
    // only show more button to post owner
    UIButton *more = (UIButton *)[cell.contentView viewWithTag:19];
    if (more) {
        if (userId != [MLApiClient client].userId) {
            more.hidden = YES;
        } else {
            more.hidden = NO;
            [more addTarget:self action:@selector(tapOnMore:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return cell;
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    NSLog(@"I am here... ");
    NSInteger postId = [self tagToPostId:[textView superview].tag];

    UITableViewCell *cell = (UITableViewCell*)[[[textView superview] superview] superview];
    [self toggleComment:postId cell:cell];
    return NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // delete post
        [[MLPostInfo instance] deletePostId:self.moreActionPostId success:^(id responseJSON) {
            if (self.commentPostCell == nil) {
                [self loadPosts];
            } else {
                self.commentPostCell = nil;
                if (self.delegate) {
                    [self.delegate postFeed:self willCloseComment:self.moreActionPostId];
                }
            }
        }];
    } else {
        // cancel delete
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"index = %d", buttonIndex);
    switch (buttonIndex) {
        case 0:
        {
            NSLog(@"share on facebook");
            if (!self.moreActionCell) {
                return;
            }
            
            UIImage *img = [self imageWithView:self.moreActionCell];
            NSArray *permissionsNeeded = @[@"publish_actions"];
            [FBSession openActiveSessionWithPublishPermissions:permissionsNeeded
                                               defaultAudience:FBSessionDefaultAudienceOnlyMe
                                                  allowLoginUI:YES
                                             completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                                 if (!error) {
                                                     NSLog(@"got publish permission");
                                                     [FBDialogs presentOSIntegratedShareDialogModallyFrom:self
                                                                                              initialText:@"share from ParentLink"
                                                                                                    image:img
                                                                                                      url:nil
                                                                                                  handler:^(FBOSIntegratedShareDialogResult result, NSError *error) {
                                                                                                      NSLog(@"dialog dismissed: %d, %@", result, error);
                                                                                                  }];
                                                     
                                                     //                     [FBDialogs presentShareDialogWithLink:nil name:postTxt handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                     //                     }];
                                                     
                                                 } else {
                                                     NSLog(@"got error: %@", error);
                                                 }
                                             }];

            break;
        }
        case 1:
        {
            NSLog(@"Share to WeChat");
            // share to WeChat
            WXMediaMessage *message = [WXMediaMessage message];
            message.title = @"share from ParentLink";
            message.description = @"try it out";
//            [message setThumbImage:img];
            UIImage *img = [self imageWithView:self.moreActionCell];
            WXImageObject *imgObj = [WXImageObject object];
            imgObj.imageData = UIImageJPEGRepresentation(img, 1.0);
            imgObj.imageUrl = @"http://parentlinkapp.com";
            message.mediaObject = imgObj;
            
            SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
            req.bText = NO;
            req.message = message;
            req.scene = WXSceneTimeline;
            [WXApi sendReq:req];
            break;
        }
        case 2:
        {
            UIAlertView *confirm = [[UIAlertView alloc] initWithTitle:@"Confirm"
                                                              message:@"Do you really want to delete this post?"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                                    otherButtonTitles:@"No", @"Yes", nil];
            [confirm show];
            break;
        }
        default:
            break;
    }
}

#pragma mark - CommentFeedDelegate
- (void)commentFeed:(CommentFeedTableViewController*)commentFeed updateCommentCount:(NSInteger)commentCount
{
    NSLog(@"update comment count to %d", commentCount);
    if (self.commentPostCell) {
        UILabel *cntLabel = (UILabel *)[self.commentPostCell.contentView viewWithTag:12];
        cntLabel.text = [NSString stringWithFormat:@"%d", commentCount];
        if (commentCount > 0) {
            UIImageView *img = (UIImageView *)[self.commentPostCell.contentView viewWithTag:16];
            img.highlighted = YES;
        }
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

- (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (NSInteger)tagToPostId:(NSInteger)tag
{
    return tag - 1000;
}

- (NSInteger)tagToUserId:(NSInteger)tag
{
    for (NSDictionary *post in self.postArray) {
        if ([post[@"id"] integerValue] == (tag-1000)) {
            return [post[@"user_id"] integerValue];
        }
    }
    return -1;
}

@end
