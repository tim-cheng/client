//
//  CommentFeedTableViewController.h
//  test1
//
//  Created by Tim Cheng on 5/12/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CommentFeedDelegate;

@interface CommentFeedTableViewController : UITableViewController

@property (nonatomic, weak) id<CommentFeedDelegate> delegate;
- (void)showComment:(NSInteger)postId;
- (void)hideComment;
@end


@protocol CommentFeedDelegate <NSObject>
@optional
- (void)commentFeed:(CommentFeedTableViewController*)commentFeed updateCommentCount:(NSInteger)commentCount;
@end