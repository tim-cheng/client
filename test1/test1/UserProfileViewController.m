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

@interface UserProfileViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *profImgView;

@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *locationField;
@property (strong, nonatomic) IBOutlet UITextField *descField;

-(IBAction)tapBack:(id)sender;
@end

@implementation UserProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.profImgView.image = [[MLUserInfo instance] userPicture:kApiClientUserSelf];
    [[MLUserInfo instance] userInfoFromId:kApiClientUserSelf success:^(id responseJSON) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"get user info: %@", responseJSON);
            NSDictionary *userInfo = (NSDictionary *)responseJSON;
            self.nameField.text = userInfo[@"full_name"];
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

@end
