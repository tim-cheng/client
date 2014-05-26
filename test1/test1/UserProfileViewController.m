//
//  UserProfileViewController.m
//  test1
//
//  Created by Tim Cheng on 5/18/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "UserProfileViewController.h"
#import "MainFeedViewController.h"
#import "MLApiClient.h"
#import "MLUserInfo.h"
#import "AddChildViewController.h"

@interface UserProfileViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *profImgView;

@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *locationField;
@property (strong, nonatomic) IBOutlet UITableView *kidsView;

@property (strong, nonatomic) NSMutableArray *kidsArray;

@property (assign, nonatomic) NSInteger editKidRow;


-(IBAction)tapBack:(id)sender;
-(IBAction)addKid:(id)sender;
@end

@implementation UserProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.kidsArray = [[NSMutableArray alloc] init];
    
    self.profImgView.image = [[MLUserInfo instance] userPicture:kApiClientUserSelf];
    [[MLUserInfo instance] userInfoFromId:kApiClientUserSelf success:^(id responseJSON) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"get user info: %@", responseJSON);
            NSDictionary *userInfo = (NSDictionary *)responseJSON;
            self.nameField.text = userInfo[@"full_name"];
        });
    }];
    
    self.kidsView.dataSource = self;
    self.kidsView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadKids];
}

-(void)loadKids
{
    [[MLApiClient client] kidsForId:kApiClientUserSelf success:^(NSHTTPURLResponse *response, id responseJSON) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self clearKids];
            NSLog(@"got kids %@", responseJSON);
            [self.kidsArray addObjectsFromArray:responseJSON];
            [self.kidsView beginUpdates];
            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
            for (int i=0; i<[self.kidsArray count]; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            [self.kidsView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [self.kidsView endUpdates];

        });

    } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self clearKids];
        });
    }];
}

-(IBAction)tapBack:(id)sender
{
    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    
    MainFeedViewController *feedController = [self.storyboard instantiateViewControllerWithIdentifier:@"feedController"];
    navigationController.viewControllers = @[feedController];
    self.frostedViewController.contentViewController = navigationController;

}

-(IBAction)addKid:(id)sender
{
    self.editKidRow = -1;
    [self performSegueWithIdentifier:@"AddKid" sender:self];
}

- (void)clearKids
{
    if ([self.kidsArray count] > 0) {
        [self.kidsView beginUpdates];
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        for (int i=0; i<[self.kidsArray count]; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        [self.kidsView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [self.kidsArray removeAllObjects];
        [indexPaths removeAllObjects];
        [self.kidsView endUpdates];
    }
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.kidsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ChildCell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *kidInfo = self.kidsArray[indexPath.row];
    UIImageView *picView = (UIImageView *)[cell.contentView viewWithTag:10];
    if ([kidInfo[@"boy"] boolValue]) {
        picView.image = [UIImage imageNamed:@"boy_color_64.png"];
    } else {
        picView.image = [UIImage imageNamed:@"girl_color_64.png"];
    }

    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:11];
    nameLabel.text = kidInfo[@"name"];

    UILabel *ageLabel = (UILabel *)[cell.contentView viewWithTag:12];
    ageLabel.text = [NSString stringWithFormat:@"%@ years old", kidInfo[@"age"]];

    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.editKidRow = indexPath.row;
    [self performSegueWithIdentifier:@"AddKid" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddKid"]) {
        AddChildViewController *childVC = segue.destinationViewController;
        if (self.editKidRow >= 0) {
            childVC.kidId = [self.kidsArray[self.editKidRow][@"id"] integerValue];
            childVC.kidName = self.kidsArray[self.editKidRow][@"name"];
            childVC.kidBirthday = @"2010-10-10";
            childVC.kidIsBoy = [self.kidsArray[self.editKidRow][@"boy"] boolValue];
        } else {
            childVC.kidId = -1;
        }
    }
}

@end
