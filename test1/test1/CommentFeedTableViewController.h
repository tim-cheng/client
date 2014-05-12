//
//  CommentFeedTableViewController.h
//  test1
//
//  Created by Tim Cheng on 5/12/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentFeedTableViewController : UITableViewController

- (void)showComment:(NSInteger)postId;
- (void)hideComment;

@end
