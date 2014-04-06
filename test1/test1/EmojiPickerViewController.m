//
//  EmojiPickerViewController.m
//  test1
//
//  Created by Tim Cheng on 4/4/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "EmojiPickerViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "RNGridMenu.h"


@interface EmojiPickerViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *emojiView;


@property (strong, nonatomic) NSMutableArray *emojiArray;


@end

@implementation EmojiPickerViewController

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
    
    NSArray *options = @[@"Read a book", @"Dinner", @"Chat", @"Question", @"Kids Said", @"Sad", @"Straight", @"LoL", @"Nervious"];
//    RNGridMenu *av = [[RNGridMenu alloc] initWithImages:self.emojiArray];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (int i=0; i<[self.emojiArray count]; i++) {
        [items addObject:[[RNGridMenuItem alloc] initWithImage:self.emojiArray[i] title:options[i]]];
    }
    RNGridMenu *av = [[RNGridMenu alloc] initWithItems:items];
    
    [av showInViewController:self center:CGPointMake(160.0f, 300.0f)];
    
    
    self.emojiView.dataSource = self;
    self.emojiView.delegate = self;
    [self.emojiView reloadData];
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

#pragma mark - UICollectionVIewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.emojiArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"EmojiCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UICollectionViewCell alloc] init];
    }
    
    UIImageView *image = (UIImageView*)[cell.contentView viewWithTag:10];
    image.image = self.emojiArray[indexPath.row];
    
    //cell.backgroundColor = [UIColor redColor];
    return cell;
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(100, 100);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(80, 0, 80, 0);
}

@end
