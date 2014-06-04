//
//  ScoreFeedViewController.m
//  test1
//
//  Created by Tim Cheng on 4/12/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "ScoreFeedViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FBClient.h"


@interface ScoreFeedViewController () <UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *lbView;

@property (strong, nonatomic) NSMutableArray *leaders;
@end

@implementation ScoreFeedViewController

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
    
    self.leaders = [[NSMutableArray alloc] init];
}

- (void) updateInfo
{
    [self.leaders addObject:@{
                              @"name" : @"Sherry Xu",
                              @"score" : @(397),
                              @"rank" : @(1),
                              @"images" : @[@"s1", @"s2", @"s3", @"s4"],
                              }];
    [self.leaders addObject:@{
                              @"name" : @"Tim Cheng",
                              @"score" : @(234),
                              @"rank" : @(1),
                              @"images" : @[@"s2", @"s4", @"s1", @"s3", @"s2", @"s3", @"s1"],
                              }];
    [self.leaders addObject:@{
                              @"name" : @"Carrie Pan",
                              @"score" : @(152),
                              @"rank" : @(1),
                              @"images" : @[@"s4", @"s3", @"s2", @"s4", @"s3", @"s1", @"s2",@"s4", @"s3", @"s1", @"s2"],
                              }];
    
    [self.leaders addObject:@{
                              @"name" : @"Claire Cheng",
                              @"score" : @(110),
                              @"rank" : @(1),
                              @"images" : @[@"s3", @"s1", @"s2",@"s4", @"s3", @"s1", @"s2"],
                              }];
    
    [self.leaders addObject:@{
                              @"name" : @"Eva Cheng",
                              @"score" : @(92),
                              @"rank" : @(1),
                              @"images" : @[@"s1", @"s2", @"s3", @"s4"],
                              }];
    
    self.lbView.dataSource = self;

    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (int i=0; i<[self.leaders count]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    [self.lbView beginUpdates];
    [self.lbView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.lbView endUpdates];
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

#pragma mark UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.leaders count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ScoreCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    UIImageView *userImg = (UIImageView *)[cell.contentView viewWithTag:10];
    FBProfilePictureView *fbPicView = [[FBProfilePictureView alloc] initWithProfileID:[FBClient client].id
                                                                      pictureCropping:FBProfilePictureCroppingSquare];
    fbPicView.frame = CGRectMake(0,0,40,40);
    [userImg addSubview:fbPicView];
    
    UILabel *userName = (UILabel *)[cell.contentView viewWithTag:11];
    userName.text = self.leaders[indexPath.row][@"name"];

    UILabel *score = (UILabel *)[cell.contentView viewWithTag:12];
    score.text = [self.leaders[indexPath.row][@"score"] stringValue];
    
    UIScrollView * imgScroll = (UIScrollView *)[cell.contentView viewWithTag:15];
    NSArray *allImgs = self.leaders[indexPath.row][@"images"];
    CGFloat cx = 0;
    for (int i=0; i<[allImgs count]; i++) {
        NSString *imgName = [NSString stringWithFormat:@"%@", allImgs[i]];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
        CGRect rect = imgView.frame;
        rect.size.height = 60;
        rect.size.width = 60;
        rect.origin.x = cx;
        rect.origin.y = 0;
        imgView.frame = rect;
        [imgScroll addSubview:imgView];
        cx += imgView.frame.size.width + 5;
    }
    imgScroll.contentSize = CGSizeMake(cx, [imgScroll bounds].size.height);
    
    return cell;
}


@end
