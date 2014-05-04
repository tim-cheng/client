//
//  LeaderboardViewController.m
//  test1
//
//  Created by Tim Cheng on 4/8/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "LeaderboardViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface LeaderboardViewController () <UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UITableView *lbView;

@property (strong, nonatomic) NSMutableArray *leaders;

@end

@implementation LeaderboardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSLog(@"initialization here...");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"initialization here...");
    
    self.titleLabel.layer.borderColor = [UIColor colorWithRed:11/256.0f green:179/256.0f blue:117/256.0f alpha:1.0f].CGColor;
    self.titleLabel.layer.borderWidth = 1.0;

    self.leaders = [[NSMutableArray alloc] init];
    
    [self.leaders addObject:@{
                             @"name" : @"Sherry Xu",
                             @"score" : @(397),
                             @"rank" : @(1)
                             }];
    
    [self.leaders addObject:@{
                              @"name" : @"Tim Cheng",
                              @"score" : @(234),
                              @"rank" : @(1)
                              }];
    
    [self.leaders addObject:@{
                              @"name" : @"Carrie Pan",
                              @"score" : @(152),
                              @"rank" : @(1)
                              }];
    
    [self.leaders addObject:@{
                              @"name" : @"Claire Cheng",
                              @"score" : @(110),
                              @"rank" : @(1)
                              }];
    
    [self.leaders addObject:@{
                              @"name" : @"Eva Cheng",
                              @"score" : @(92),
                              @"rank" : @(1)
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
    static NSString *cellIdentifier = @"LeaderCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }

    UIColor *myGreen = [UIColor colorWithRed:11/256.0f green:179/256.0f blue:117/256.0f alpha:1.0f];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, 1, cell.contentView.bounds.size.height)];
    lineView.backgroundColor = myGreen;
    lineView.autoresizingMask = 0x3f;
    [cell.contentView insertSubview:lineView atIndex:0];

    lineView = [[UIView alloc] initWithFrame:CGRectMake(300, 0, 1, cell.contentView.bounds.size.height)];
    lineView.backgroundColor = myGreen;
    lineView.autoresizingMask = 0x3f;
    [cell.contentView insertSubview:lineView atIndex:0];

    if (indexPath.row == [self.leaders count] -1) {
        lineView = [[UIView alloc] initWithFrame:CGRectMake(20, cell.contentView.bounds.size.height, 281, 1)];
        lineView.backgroundColor = myGreen;
        lineView.autoresizingMask = 0x3f;
        [cell.contentView insertSubview:lineView atIndex:0];
    }
    
    UIView *rankView = (UIView *)[cell.contentView viewWithTag:10];
    if (rankView) {
        CAShapeLayer *circleLayer = [[CAShapeLayer alloc] init];
        circleLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(3, 3, 24, 24)].CGPath;
        CGFloat adj = (1-indexPath.row*0.333) >= 0 ? (1-indexPath.row*0.333) : 0;
        circleLayer.fillColor = [UIColor colorWithRed:11/256.0f green:179/256.0f blue:117/256.0f alpha:1.0f*adj].CGColor;
        circleLayer.strokeColor = myGreen.CGColor;
        circleLayer.lineWidth = 0.5;
        [rankView.layer insertSublayer:circleLayer atIndex:0];
        
        UILabel *rankLabel = [[UILabel alloc] initWithFrame:rankView.bounds];
        [rankLabel setFont:[UIFont fontWithName:@"Helvetica Neue Bold" size:14.0f]];
        rankLabel.textAlignment = NSTextAlignmentCenter;
        if (indexPath.row >= 3) {
            rankLabel.textColor = myGreen;
        } else {
            rankLabel.textColor = [UIColor whiteColor];
        }
        rankLabel.text = [NSString stringWithFormat:@"%d", indexPath.row + 1];
        rankLabel.backgroundColor = [UIColor clearColor];
        [rankView addSubview:rankLabel];
    }
    
    UIImageView *profileImg = (UIImageView*)[cell.contentView viewWithTag:11];
    if (profileImg) {
        profileImg.image = [UIImage imageNamed:@"sherry.png"];
    }
    
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:12];
    if (nameLabel) {
        nameLabel.text = self.leaders[indexPath.row][@"name"];
    }
    
    UILabel *scoreLabel = (UILabel *)[cell.contentView viewWithTag:13];
    if (scoreLabel) {
        scoreLabel.text = [(NSNumber *)self.leaders[indexPath.row][@"score"] stringValue];
    }
    
    
    return cell;
}

@end
