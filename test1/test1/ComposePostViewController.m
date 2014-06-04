//
//  ComposePostViewController.m
//  test1
//
//  Created by Tim Cheng on 4/5/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "ComposePostViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "RNGridMenu.h"


@interface ComposePostViewController () <RNGridMenuDelegate>

@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UITextView *statusView;
@property (strong, nonatomic) IBOutlet UIButton *fbButton;

@property (strong, nonatomic) IBOutlet UIImageView *mainIcon;


@property (strong, nonatomic) NSMutableArray *emojiArray;

@end

@implementation ComposePostViewController

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
    
    // Do any additional setup after loading the view.
    self.profilePictureView.profileID = self.fbID;
    self.profilePictureView.layer.cornerRadius = 10.0f;
    self.nameLabel.text = self.fbName ? self.fbName : @"Not Logged In";
    
    self.emojiArray = [[NSMutableArray alloc] init];
    [self.emojiArray addObjectsFromArray:@[
                                           [UIImage imageNamed:@"emoticon_lol.png"],
                                           [UIImage imageNamed:@"emoticon_nervous.png"],
                                           [UIImage imageNamed:@"emoticon_oh_no.png"],
                                           [UIImage imageNamed:@"emoticon_smile.png"],
                                           [UIImage imageNamed:@"emoticon_happy.png"],
                                           [UIImage imageNamed:@"emoticon_sad.png"],
                                           [UIImage imageNamed:@"emoticon_straight_face.png"],
                                           [UIImage imageNamed:@"emoticon_lol.png"],
                                           [UIImage imageNamed:@"emoticon_nervous.png"],
                                           ]];
    
    NSArray *options = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"];
    //    RNGridMenu *av = [[RNGridMenu alloc] initWithImages:self.emojiArray];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (int i=0; i<[self.emojiArray count]; i++) {
        [items addObject:[[RNGridMenuItem alloc] initWithImage:self.emojiArray[i] title:options[i]]];
    }
    RNGridMenu *av = [[RNGridMenu alloc] initWithItems:items];
    av.delegate = self;
    
    [av showInViewController:self center:CGPointMake(160.0f, 300.0f)];
    
    self.statusView.layer.borderWidth = 1.0f;
    self.statusView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.statusView.layer.cornerRadius = 5;
    
    self.fbButton.selected = NO;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - RNGridMenuDelegate
- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex
{
    NSLog(@"delegate!");
    self.mainIcon.image = self.emojiArray[itemIndex];
}


@end
