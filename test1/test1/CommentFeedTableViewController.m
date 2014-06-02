//
//  CommentFeedTableViewController.m
//  test1
//
//  Created by Tim Cheng on 5/12/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "CommentFeedTableViewController.h"
#import "MLApiClient.h"
#import "MLUserInfo.h"
#import "NSDate+TimeAgo.h"
#import "MLHelpers.h"

@interface CommentFeedTableViewController() <UITableViewDataSource, UITextFieldDelegate, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *commentArray;
@property (strong, nonatomic) NSDateFormatter *myFormatter;
@property (assign, nonatomic) NSInteger commentPostId;
@property (strong, nonatomic) IBOutlet UITextField *commentField;
@property (strong, nonatomic) IBOutlet UIView *composeView;

-(IBAction)tapPost:(id)sender;

@end

@implementation CommentFeedTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.composeView.frame.size.width, 1.0f);
    topBorder.backgroundColor = [MLColor CGColor];
    [self.composeView.layer addSublayer:topBorder];
    
    // Do any additional setup after loading the view.
    self.myFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [self.myFormatter setLocale:enUSPOSIXLocale];
    [self.myFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSSSS'Z'"];
    [self.myFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"US/Eastern"]];
    
    self.commentArray = [[NSMutableArray alloc] initWithCapacity:100];
    self.commentField.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)showComment:(NSInteger)postId
{
    [self loadCommentsForPostId:postId];
    self.tableView.hidden = NO;
}

- (void)hideComment
{
    self.tableView.hidden = YES;
    [self clearComments];
    [self.commentField resignFirstResponder];
    self.tableView.frame = CGRectMake(0,320,320,248);
}

- (void)clearComments
{
    if ([self.commentArray count] > 0) {
        [self.tableView beginUpdates];
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        for (int i=0; i<[self.commentArray count]; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [self.commentArray removeAllObjects];
        [indexPaths removeAllObjects];
        [self.tableView endUpdates];
    }
}

- (void)loadCommentsForPostId:(NSInteger)postId
{
    self.commentPostId = postId;
    [[MLApiClient client] commentsFromId:postId
                                 success:^(NSHTTPURLResponse *response, id responseJSON) {
                                     NSLog(@"!!!!get comments succeeded!!!!, %@", responseJSON);
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         [self.tableView beginUpdates];
                                         NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
                                         for (int i=0; i<[self.commentArray count]; i++) {
                                             [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                                         }
                                         [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                                         [self.commentArray removeAllObjects];
                                         [indexPaths removeAllObjects];
                                         [self.commentArray addObjectsFromArray:responseJSON];
                                         for (int i=0; i<[self.commentArray count]; i++) {
                                             [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                                         }
                                         [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                                         [self.tableView endUpdates];
                                         if ([self.commentArray count] > 0) {
                                             [self.tableView scrollToRowAtIndexPath:indexPaths[[self.commentArray count]-1]
                                                                      atScrollPosition:UITableViewScrollPositionTop
                                                                              animated:NO];
                                         }
                                         if (self.delegate) {
                                             [self.delegate commentFeed:self updateCommentCount:[self.commentArray count]];
                                         }
                                     });
                                 } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
                                     NSLog(@"!!!!!get comments failed");
//                                     dispatch_async(dispatch_get_main_queue(), ^{
//                                         [self clearComments];
//                                     });
                                 }];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.commentArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // comment view
    static NSString *cellIdentifier = @"CommentCell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSInteger userId = [self.commentArray[indexPath.row][@"user_id"] integerValue];
    
    UIImageView *userImg = (UIImageView*)[cell.contentView viewWithTag:10];
    userImg.image = [[MLUserInfo instance] userPicture:userId];
    userImg.layer.borderWidth = 1.0f;
    userImg.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    userImg.layer.cornerRadius = 16;
    userImg.clipsToBounds = YES;
    
    // set commenter name
    UILabel *name = (UILabel *)[cell.contentView viewWithTag:13];
    [[MLUserInfo instance] userInfoFromId:userId success:^(id responseJSON) {
        dispatch_async(dispatch_get_main_queue(), ^{
            name.text = responseJSON[@"full_name"];
        });
    }];
    
    // set comment body
    UILabel *comment = (UILabel *)[cell.contentView viewWithTag:11];
    comment.text = self.commentArray[indexPath.row][@"body"];
    comment.numberOfLines = 0;
    CGRect newFrame = comment.frame;
    newFrame.size.height = [self commentLabelHeight:comment.text];
    comment.frame = newFrame;
    
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

#pragma mark - UITextFieldDelgate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
//    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 216, 0);
    CGFloat height = [self.tableView sizeThatFits:self.tableView.frame.size].height + 212.0f;
    if (height > 248.0f) {
        // need to adjust frame size
        CGFloat y = 320 - (height - 248);
        self.tableView.frame = CGRectMake(0, y, 320, 248);
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length <= 0) {
        return NO;
    }
    
    NSLog(@"should return........");
    [self postComment];
    return YES;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = self.commentArray[indexPath.row][@"body"];
    CGFloat height = [self commentLabelHeight:text];
    return height + 24.0f;
}

#pragma mark - IBAction
-(IBAction)tapPost:(id)sender
{
    if (self.commentField.text.length <= 0) {
        return;
    }
    [self postComment];
}

- (void)postComment
{
    [self.commentField resignFirstResponder];
    self.tableView.frame = CGRectMake(0, 320, 320, 248);
    
    //self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    // post comments
    NSString *txt = self.commentField.text;
    self.commentField.text = @"";
    [[MLApiClient client] sendCommentFromId:[MLApiClient client].userId
                                     postId:self.commentPostId
                                       body:txt
                                    success:^(NSHTTPURLResponse *response, id responseJSON) {
                                        NSLog(@"!!!!post comment succeeded");
                                        if (self.commentPostId) {
                                            [self loadCommentsForPostId:self.commentPostId];
                                        }
                                    } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
                                        NSLog(@"!!!!post comment failed");
                                    }];
}

#pragma mark - helper

- (CGFloat)commentLabelHeight:(NSString *)text
{
    CGSize constraintSize = CGSizeMake(250.0f, 150.0f);
    return [text sizeWithFont:[UIFont fontWithName:@"bariol-regular" size:17.0]
            constrainedToSize:constraintSize
                lineBreakMode:NSLineBreakByWordWrapping].height;
}

@end
