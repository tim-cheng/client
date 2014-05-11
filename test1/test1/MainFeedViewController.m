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
#import "MLPostInfo.h"
#import "NSDate+TimeAgo.h"
#import "UIImage+ImageEffects.h"


@interface MainFeedViewController () <UITableViewDataSource,
                                      UITextViewDelegate,
                                      UITextFieldDelegate,
                                      UIImagePickerControllerDelegate,
                                      UINavigationControllerDelegate,
                                      UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSMutableArray *postArray;
@property (strong, nonatomic) NSMutableArray *commentArray;

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UILabel *headerName;
@property (strong, nonatomic) IBOutlet UILabel *headerConnections;

@property (strong, nonatomic) IBOutlet UITableView *mainFeedView;
@property (strong, nonatomic) IBOutlet UITextView *postTextView;

@property (strong, nonatomic) IBOutlet UIView *composeView;
@property (strong, nonatomic) IBOutlet UIButton *composeCameraButton;
@property (strong, nonatomic) IBOutlet UIButton *composeswitchButton;
@property (strong, nonatomic) UIImage *composeBgImg;
@property (assign, nonatomic) NSInteger composeBgImgBlurLvl;

@property (strong, nonatomic) IBOutlet UITableView *commentFeedView;
@property (strong, nonatomic) IBOutlet UITextField *commentField;
@property (assign, nonatomic) NSInteger commentPostId;

@property (strong, nonatomic) NSDateFormatter *myFormatter;

- (IBAction)compose:(id)sender;
- (IBAction)composeSelectImage:(id)sender;
- (IBAction)composeShuffleBackground:(id)sender;
- (IBAction)closeComment:(UIButton *)button;

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
                                          self.headerConnections.text = [NSString stringWithFormat:@"%d 1°   %d 2°", [responseJSON[@"num_degree1"] integerValue], [responseJSON[@"num_degree2"] integerValue]];
                                      });
                                  }];
    
    // prepare composeView
    [self.postTextView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    self.postTextView.delegate = self;
    
    self.commentField.delegate = self;
    
    self.profileImage.image = [[MLUserInfo instance] userPicture:[MLApiClient client].userId];
    self.profileImage.layer.borderWidth = 1.0f;
    self.profileImage.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.profileImage.layer.cornerRadius = 20;
    self.profileImage.clipsToBounds = YES;
    
    self.mainFeedView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self loadPostsAndScroll:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadPostsAndScroll:(BOOL)needScroll
{
    [[MLPostInfo instance] loadPostInfoFromId:[MLApiClient client].userId
                                       degree:1
                                      success:^(id responseJSON) {
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
                                              if (needScroll) {
                                                  // scroll to top
                                                  [self.mainFeedView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                                              }
                                          });
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
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      // remove all comments
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
                                      [self.commentFeedView endUpdates];
                                  });
                              }];
}

#pragma mark - GestureRecognizer

- (void)toggleComment:(NSInteger)postId cell:(UITableViewCell *)cell open:(BOOL)open
{
    if (open) {
        NSIndexPath *indexPath = [self.mainFeedView indexPathForCell:cell];
        if (self.commentFeedView.hidden) {
            self.commentPostId = postId;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.headerView.hidden = YES;
                CGRect newFrame = self.mainFeedView.frame;
                newFrame.origin.y = 0;
                self.mainFeedView.frame = newFrame;
                [self.mainFeedView scrollToRowAtIndexPath:indexPath
                                         atScrollPosition:UITableViewScrollPositionTop
                                                 animated:NO];
                self.mainFeedView.scrollEnabled = NO;
                self.commentFeedView.hidden = NO;
                self.commentFeedView.dataSource = self;
                NSLog(@"post id = %d\n", self.commentPostId);
                [self loadCommentsForPostId:self.commentPostId];
                [UIApplication sharedApplication].statusBarHidden = YES;
            });
        }
    } else {
        self.commentPostId = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.headerView.hidden = NO;
            CGRect newFrame = self.mainFeedView.frame;
            newFrame.origin.y = 68;
            //                newFrame.size.height = 520;
            self.mainFeedView.frame = newFrame;
            self.mainFeedView.scrollEnabled = YES;
            self.commentFeedView.hidden = YES;
            self.commentFeedView.dataSource = nil;
            [self.commentField resignFirstResponder];
            [self loadPostsAndScroll:NO];
            [UIApplication sharedApplication].statusBarHidden = NO;
            // remove comments from commentfeedview
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
            [self.commentFeedView endUpdates];
        });
    }
}

- (void)tapOnComment:(UITapGestureRecognizer *)gest
{
    UIImageView *img = (UIImageView*)gest.view;
    NSInteger postId = [img superview].tag - 1000;
    UITableViewCell *cell = (UITableViewCell*)[[[img superview] superview] superview];
    [self toggleComment:postId cell:cell open:(self.commentPostId == 0)];
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

- (void) SwipeRecognizer:(UISwipeGestureRecognizer *)sender {
    if (sender.direction == UISwipeGestureRecognizerDirectionRight){
        NSLog(@" *** WRITE CODE FOR SWIPE RIGHT ***");
        UITextView *textView = (UITextView *)sender.view;
        UIImageView *imageView = (UIImageView *)[[textView superview] viewWithTag:30];
        if (imageView) {
            self.composeBgImgBlurLvl++;
            imageView.image = [self.composeBgImg applyBlurWithRadius:2
                                                     iterationsCount:self.composeBgImgBlurLvl
                                                           tintColor:[UIColor colorWithWhite:0.2 alpha:0.2]
                                               saturationDeltaFactor:1.8
                                                           maskImage:nil];
        }
    } else if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@" *** WRITE CODE FOR SWIPE LEFT ***");
        if (self.composeBgImgBlurLvl > 0) {
            UITextView *textView = (UITextView *)sender.view;
            UIImageView *imageView = (UIImageView *)[[textView superview] viewWithTag:30];
            if (imageView) {
                self.composeBgImgBlurLvl--;
                imageView.image = [self.composeBgImg applyBlurWithRadius:2
                                                         iterationsCount:self.composeBgImgBlurLvl
                                                               tintColor:[UIColor colorWithWhite:0.2 alpha:0.2]
                                                   saturationDeltaFactor:1.8
                                                               maskImage:nil];
            }
        }
    }
}

#pragma mark - UITableViewDataSource

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
            UIImage *image = [[MLPostInfo instance] postPicture:postId];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.tag = 30;
//            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [cell.contentView addSubview:imageView ];
            [cell.contentView sendSubviewToBack:imageView ];
        }

        UITextView *postTextView = (UITextView *)[cell.contentView viewWithTag:10];
        if (postTextView) {
            postTextView.text = self.postArray[indexPath.row][@"body"];
            //[postTextView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
            postTextView.delegate = self;
            [self observeValueForKeyPath:nil ofObject:postTextView change:nil context:nil];
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
        UIImageView *userImg = (UIImageView*)[cell.contentView viewWithTag:10];
        userImg.image = [[MLUserInfo instance] userPicture:[self.commentArray[indexPath.row][@"user_id"] integerValue]];
        userImg.layer.borderWidth = 1.0f;
        userImg.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        userImg.layer.cornerRadius = 16;
        userImg.clipsToBounds = YES;

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

#pragma mark - UITextFieldDelgate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.commentFeedView.contentInset = UIEdgeInsetsMake(0, 0, 216, 0);
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"should return........");
    [textField resignFirstResponder];
    self.commentFeedView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    // post comments
    NSString *txt = textField.text;
    textField.text = @"";
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
    
    return YES;
}

#pragma mark - UITextViewDelgate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (textView == self.postTextView) {
        textView.text = @"";
        return YES;
    } else {
        NSInteger postId = [textView superview].tag - 1000;
        UITableViewCell *cell = (UITableViewCell*)[[[textView superview] superview] superview];
        [self toggleComment:postId cell:cell open:(self.commentPostId == 0)];
        return NO;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView == self.postTextView) {
        if([text isEqualToString:@"\n"]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - UIImagePickerControllerDelegate

- (void) imagePickerController:(UIImagePickerController *)picker
         didFinishPickingImage:(UIImage *)image
                   editingInfo:(NSDictionary *)editingInfo
{
    // remove originial
    UIImageView *imageView = (UIImageView *)[[self.postTextView superview] viewWithTag:30];
    if (imageView) {
        [imageView removeFromSuperview];
    }

    // crop
    CGRect newRect;
    if (image.size.width < image.size.height) {
        float offset = (image.size.height - image.size.width) / 2;
        // note, CGImage is not rotated
        newRect = CGRectMake(offset, 0, image.size.width, image.size.width);
    } else {
        float offset = (image.size.width - image.size.height) / 2;
        newRect = CGRectMake(offset, 0, image.size.height, image.size.height);
    }
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], newRect);
    UIImage *cropImage = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(imageRef);

    // scale
    CGSize newSize = self.postTextView.frame.size;
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [cropImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    [self dismissModalViewControllerAnimated:YES];
    UIGraphicsEndImageContext();
    
    self.composeBgImg = newImage;
    self.composeBgImgBlurLvl = 0;
    
    imageView = [[UIImageView alloc] initWithImage:newImage];
    imageView.tag = 30;
    [[self.postTextView superview] insertSubview:imageView belowSubview:self.postTextView];
    self.postTextView.backgroundColor = [UIColor clearColor];
    [self observeValueForKeyPath:nil ofObject:self.postTextView change:nil context:nil];
    
    UISwipeGestureRecognizer *recognizerR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(SwipeRecognizer:)];
    recognizerR.direction = UISwipeGestureRecognizerDirectionRight;
    recognizerR.numberOfTouchesRequired = 1;
    recognizerR.delegate = self;
    [self.postTextView addGestureRecognizer:recognizerR];

    UISwipeGestureRecognizer *recognizerL = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(SwipeRecognizer:)];
    recognizerL.direction = UISwipeGestureRecognizerDirectionLeft;
    recognizerL.numberOfTouchesRequired = 1;
    recognizerL.delegate = self;
    [self.postTextView addGestureRecognizer:recognizerL];

}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIView class]])
    {
        return YES;
    }
    return NO;
}

#pragma mark - IBAction
- (IBAction)compose:(id)sender
{
    self.composeView.hidden = !self.composeView.hidden;
    UIButton *icon = (UIButton *)sender;
    if (!self.composeView.hidden) {
        // composing
        dispatch_async(dispatch_get_main_queue(), ^{
            icon.imageView.image = [UIImage imageNamed:@"post_64.png"];
        });
    } else {
        NSString *txt = self.postTextView.text;
        if ([txt isEqualToString:@"Share what's new"]) {
            return;
        }
        [self.postTextView resignFirstResponder];
        
        UIImageView *imagView = (UIImageView *)[[self.postTextView superview] viewWithTag:30];
        [[MLPostInfo instance] postInfoFromId:kApiClientUserSelf
                                         body:txt
                                        image:imagView.image
                                      success:^(id responseJSON) {
                                          [self loadPostsAndScroll:YES];
                                      }];
        dispatch_async(dispatch_get_main_queue(), ^{
            icon.imageView.image = [UIImage imageNamed:@"compose2_64.png"];
            self.postTextView.text = @"Share what's new";
            [imagView removeFromSuperview];
            self.postTextView.backgroundColor = [UIColor colorWithRed:0.0991371 green:0.310455 blue:0.515286 alpha:1.0];
        });
    }
    
}

- (IBAction)composeSelectImage:(id)sender
{
    UIImagePickerController *pickerController = [[UIImagePickerController alloc]
                                                 init];
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:NULL];
}

- (IBAction)composeShuffleBackground:(UIButton *)button
{
    
}

- (IBAction)closeComment:(UIButton *)button
{
}

#pragma mark - Observer

// http://stackoverflow.com/questions/22013768/center-the-text-in-a-uitextview-vertical-and-horizontal-align
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UITextView *txtview = object;
    CGFloat topoffset = ([txtview bounds].size.height - [txtview contentSize].height * [txtview zoomScale])/2.0;
    //NSLog(@"!!!bounds =%f, %f", [txtview contentSize].width, [txtview contentSize].height);
    topoffset = ( topoffset < 0.0 ? 0.0 : topoffset );
    txtview.contentOffset = (CGPoint){.x = 0, .y = -topoffset};
}


@end
