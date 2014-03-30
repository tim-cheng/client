//
//  ProfileViewController.m
//  test1
//
//  Created by Tim Cheng on 3/25/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "ProfileViewController.h"
#import <Firebase/Firebase.h>
#import "DBClient.h"

@interface ProfileViewController () <UITableViewDataSource>

@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UITableView *friendsView;


- (IBAction) didTapBackButton:(id)sender;
- (IBAction) didTapConnectButton:(id)sender;
@end

@implementation ProfileViewController

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
    self.nameLabel.text = self.fbName;
    
//    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//        if (!error) {
//            // Success! Include your code to handle the results here
//            // NSLog(@"user info: %@", result);
//        } else {
//            // An error occurred, we need to handle the error
//            // See: https://developers.facebook.com/docs/ios/errors
//        }
//    }];

    self.friendsView.dataSource = self;
    NSLog(@"profile friends: %@", self.friends);
    
    for (NSString *fid in self.friends) {
        NSArray *indexPaths = @[[NSIndexPath indexPathForRow:0 inSection:0]];
        [self.friendsView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) didTapBackButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) didTapConnectButton:(id)sender
{
    [self performSegueWithIdentifier:@"ProfileConnect" sender:self];
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
    return [self.friends count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FriendCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSString *fid = self.friends[indexPath.row];
    
    cell.textLabel.text = fid;
    cell.detailTextLabel.text = fid;
    
    NSString *userLoc = [DBClient urlForUserId:fid];
    Firebase *profileRef = [[Firebase alloc] initWithUrl:[userLoc stringByAppendingString:@"/profile"]];
    [profileRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"profile: %@", snapshot.value);
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ - %@", snapshot.value[@"first_name"], snapshot.value[@"last_name"], snapshot.value[@"email"]];
//        cell.detailTextLabel.text = snapshot.value[@"email"];
    }];

    return cell;
}

@end
