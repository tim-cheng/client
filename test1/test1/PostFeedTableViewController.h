//
//  PostFeedTableViewController.h
//  test1
//
//  Created by Tim Cheng on 5/12/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CommentFeedTableViewController.h"

@protocol PostFeedDelegate;


@interface PostFeedTableViewController : UITableViewController <CommentFeedDelegate>
- (void)loadPostsAndScroll:(BOOL)needScroll;
@property (nonatomic, weak) id<PostFeedDelegate> delegate;
@property (assign, nonatomic) NSInteger initPostId;
@end


@protocol PostFeedDelegate <NSObject>
@optional
- (void)postFeed:(PostFeedTableViewController*)postFeed willOpenComment:(NSInteger)postId atIndexPath:(NSIndexPath *)indexPath;
- (void)postFeed:(PostFeedTableViewController*)postFeed willCloseComment:(NSInteger)postId;
@end
