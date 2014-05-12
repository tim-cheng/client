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
#import "PostFeedTableViewController.h"

#define kFeedPostTextViewHeight 228.0f
#define kComposeTextViewHeight 320.f


@interface MainFeedViewController () <UITableViewDataSource,
                                      UITextViewDelegate,
                                      UITextFieldDelegate,
                                      UIImagePickerControllerDelegate,
                                      UINavigationControllerDelegate,
                                      UIGestureRecognizerDelegate,
                                      PostFeedDelegate>

@property (strong, nonatomic) NSMutableArray *commentArray;

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UILabel *headerName;
@property (strong, nonatomic) IBOutlet UILabel *headerConnections;

@property (strong, nonatomic) IBOutlet UIView *composeHeaderView;
@property (strong, nonatomic) IBOutlet UIButton *sendPostButton;

@property (strong, nonatomic) PostFeedTableViewController *postFeedVC;
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
- (IBAction)sendPost:(UIButton *)button;
- (IBAction)cancelPost:(id)sender;

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
    self.postTextView.delegate = self;
    self.postTextView.text = @"Share what's new";
    [self textViewDidChange:self.postTextView];
    
    self.commentField.delegate = self;
    
    self.profileImage.image = [[MLUserInfo instance] userPicture:[MLApiClient client].userId];
    self.profileImage.layer.borderWidth = 1.0f;
    self.profileImage.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.profileImage.layer.cornerRadius = 20;
    self.profileImage.clipsToBounds = YES;
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    self.postFeedVC = (PostFeedTableViewController *)[sb instantiateViewControllerWithIdentifier:@"PostTable"];
    self.postFeedVC.delegate = self;
    self.mainFeedView = self.postFeedVC.tableView;

    CGRect newFrame = self.mainFeedView.frame;
    newFrame.origin.y = 68;
    self.mainFeedView.frame = newFrame;
    [self.view insertSubview:self.mainFeedView belowSubview:self.composeView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView == self.postTextView) {
        if([text isEqualToString:@"\n"]) {
            if (textView.contentSize.height > 220.0f) {
                return NO;
            }
        }
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView == self.postTextView) {
        NSString *newString = textView.text;
        if (newString.length <= 0 || [newString isEqualToString:@"Share what's new"]) {
            self.sendPostButton.hidden = YES;
        } else {
            self.sendPostButton.hidden = NO;
        }
        
        float height = [textView sizeThatFits:textView.frame.size].height;
        textView.contentInset = UIEdgeInsetsMake((kComposeTextViewHeight-height)/2, 0, 0, 0);
    }
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

#pragma mark - PostFeedDelegate
- (void)postFeed:(PostFeedTableViewController*)postFeed willOpenComment:(NSInteger)postId atIndexPath:(NSIndexPath *)indexPath
{
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
}

- (void)postFeed:(PostFeedTableViewController*)postFeed willCloseComment:(NSInteger)postId
{
    self.commentPostId = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.headerView.hidden = NO;
        CGRect newFrame = self.mainFeedView.frame;
        newFrame.origin.y = 68;
        self.mainFeedView.frame = newFrame;
        self.mainFeedView.scrollEnabled = YES;
        self.commentFeedView.hidden = YES;
        self.commentFeedView.dataSource = nil;
        [self.commentField resignFirstResponder];
        [self.postFeedVC loadPostsAndScroll:NO];
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

#pragma mark - IBAction
- (IBAction)compose:(id)sender
{
    self.composeView.hidden = NO;
    self.composeHeaderView.hidden = NO;
}

- (IBAction)sendPost:(id)sender
{
    self.composeView.hidden = YES;
    self.composeHeaderView.hidden = YES;

    NSString *txt = self.postTextView.text;
    if ([txt isEqualToString:@"Share what's new"]) {
        return;
    }
    [self.postTextView resignFirstResponder];
    
    UIImageView *imagView = (UIImageView *)[[self.postTextView superview] viewWithTag:30];
    [[MLPostInfo instance] postInfoFromId:kApiClientUserSelf
                                     body:txt
                                    image:imagView.image
                                  bgColor:self.postTextView.backgroundColor
                                  success:^(id responseJSON) {
                                      [self.postFeedVC loadPostsAndScroll:YES];
                                  }];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.postTextView.text = @"Share what's new";
        [imagView removeFromSuperview];
        self.postTextView.backgroundColor = [UIColor colorWithRed:0.0991371 green:0.310455 blue:0.515286 alpha:1.0];
    });
}

- (IBAction)cancelPost:(id)sender
{
    self.composeView.hidden = YES;
    self.composeHeaderView.hidden = YES;
    [self.postTextView resignFirstResponder];
    self.postTextView.text = @"Share what's new";
    self.postTextView.backgroundColor = [UIColor colorWithRed:0.0991371 green:0.310455 blue:0.515286 alpha:1.0];
    self.sendPostButton.hidden = YES;
    UIImageView *imagView = (UIImageView *)[[self.postTextView superview] viewWithTag:30];
    [imagView removeFromSuperview];
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
    
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    self.postTextView.backgroundColor = color;
}

- (IBAction)closeComment:(UIButton *)button
{
}



@end
