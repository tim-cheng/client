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
#import "CommentFeedTableViewController.h"
#import "MainNavigationController.h"
#import "MLHelpers.h"

#define kFeedPostTextViewHeight 228.0f
#define kComposeTextViewHeight 320.f


@interface MainFeedViewController () <UITextViewDelegate,
                                      UIImagePickerControllerDelegate,
                                      UINavigationControllerDelegate,
                                      UIGestureRecognizerDelegate,
                                      PostFeedDelegate,
                                      UIActionSheetDelegate>

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

@property (strong, nonatomic) CommentFeedTableViewController *commentFeedVC;
@property (strong, nonatomic) IBOutlet UITableView *commentFeedView;
@property (assign, nonatomic) NSInteger commentPostId;
@property (strong, nonatomic) NSDateFormatter *myFormatter;

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
    //[self.navigationController setNavigationBarHidden:YES];
    // prepare composeView
    self.postTextView.delegate = self;
    self.postTextView.text = MLDefaultPost;
    [self textViewDidChange:self.postTextView];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    self.postFeedVC = (PostFeedTableViewController *)[sb instantiateViewControllerWithIdentifier:@"PostTable"];
    self.postFeedVC.delegate = self;
    // TODO: to fix...
    self.postFeedVC.initPostId = self.initPostId;
    self.postFeedVC.initUserId = self.initUserId;
    self.postFeedVC.initDegree = self.initDegree;
    self.initPostId = 0;
    self.mainFeedView = self.postFeedVC.tableView;
    self.mainFeedView.frame = CGRectMake(0, 64.0f, 320.0f, 504.0f);
    [self.view insertSubview:self.mainFeedView belowSubview:self.composeView];
    
    
    self.commentFeedVC = (CommentFeedTableViewController *)[sb instantiateViewControllerWithIdentifier:@"CommentTable"];
    self.commentFeedView = self.commentFeedVC.tableView;
    self.commentFeedView.frame = CGRectMake(0, 320.0f, 320.0f, 248.0f);
    self.commentFeedView.hidden = YES;
    [self.view insertSubview:self.commentFeedView aboveSubview:self.mainFeedView];
    
    // update
    self.commentFeedVC.delegate = self.postFeedVC;
    
    if (self.feedTitle) {
        self.navigationController.navigationBar.topItem.title = self.feedTitle;
    } else {
        self.navigationController.navigationBar.topItem.title = @"Feed";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        if (newString.length <= 0 || [newString isEqualToString:MLDefaultPost]) {
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
    if (self.commentPostId == 0) {
        self.commentPostId = postId;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController setNavigationBarHidden:YES];
            CGRect newFrame = self.mainFeedView.frame;
            newFrame.origin.y = 0;
            self.mainFeedView.frame = newFrame;
            [self.mainFeedView scrollToRowAtIndexPath:indexPath
                                     atScrollPosition:UITableViewScrollPositionTop
                                             animated:NO];
            self.mainFeedView.scrollEnabled = NO;
            [self.commentFeedVC showComment:self.commentPostId];
            [UIApplication sharedApplication].statusBarHidden = YES;
        });
    }
}

- (void)postFeed:(PostFeedTableViewController*)postFeed willCloseComment:(NSInteger)postId
{
    self.commentPostId = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController setNavigationBarHidden:NO];
        CGRect newFrame = self.mainFeedView.frame;
        newFrame.origin.y = 64;
        self.mainFeedView.frame = newFrame;
        self.mainFeedView.scrollEnabled = YES;
        [self.commentFeedVC hideComment];
        [self.postFeedVC loadPostsAndScroll:NO];
        [UIApplication sharedApplication].statusBarHidden = NO;
    });
}

- (void)postFeed:(PostFeedTableViewController*)postFeed willOpenProfile:(NSInteger)userId
{
    MainNavigationController *nav = (MainNavigationController *)self.navigationController;
    [nav switchToProfileForUserId:userId];
}

- (void)doCompose
{
    NSLog(@"!!!!I am here");
    [self.navigationController setNavigationBarHidden:YES];
    self.composeView.hidden = NO;
    self.composeHeaderView.hidden = NO;
}

#pragma mark - IBAction

- (IBAction)sendPost:(id)sender
{
    [self.navigationController setNavigationBarHidden:NO];
    self.composeView.hidden = YES;
    self.composeHeaderView.hidden = YES;

    NSString *txt = self.postTextView.text;
    if ([txt isEqualToString:MLDefaultPost]) {
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
        self.postTextView.text = MLDefaultPost;
        [imagView removeFromSuperview];
        self.postTextView.backgroundColor = [UIColor colorWithRed:0.0991371 green:0.310455 blue:0.515286 alpha:1.0];
    });
}

- (IBAction)cancelPost:(id)sender
{
    [self.navigationController setNavigationBarHidden:NO];
    self.composeView.hidden = YES;
    self.composeHeaderView.hidden = YES;
    [self.postTextView resignFirstResponder];
    self.postTextView.text = MLDefaultPost;
    self.postTextView.backgroundColor = [UIColor colorWithRed:0.0991371 green:0.310455 blue:0.515286 alpha:1.0];
    self.sendPostButton.hidden = YES;
    UIImageView *imagView = (UIImageView *)[[self.postTextView superview] viewWithTag:30];
    [imagView removeFromSuperview];
}

- (IBAction)composeSelectImage:(id)sender
{
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Take Photo", @"Choose Exising", nil];
    [popup showInView:[UIApplication sharedApplication].keyWindow];
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

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *pickerController = [[UIImagePickerController alloc]
                                                 init];
    pickerController.delegate = self;
    pickerController.sourceType = (buttonIndex == 0) ?
       UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:pickerController animated:YES completion:NULL];
}

@end
