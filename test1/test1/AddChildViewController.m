//
//  AddChildViewController.m
//  test1
//
//  Created by Tim Cheng on 5/14/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "AddChildViewController.h"
#import "MLUserInfo.h"
#import "MLApiClient.h"

@interface AddChildViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *bdField;
@property (strong, nonatomic) IBOutlet UISwitch *typeSwitch;

@property (strong, nonatomic) IBOutlet UIButton *doneButton;


-(IBAction)tapDone:(id)sender;
-(IBAction)tapBack:(id)sender;

@end
@implementation AddChildViewController

-(void)viewDidLoad
{
    self.nameField.delegate = self;
    self.bdField.delegate = self;
    if (self.kidId >= 0) {
        self.nameField.text = self.kidName;
        self.bdField.text = self.kidBirthday;
        self.typeSwitch.enabled = self.kidIsBoy;
        self.doneButton.titleLabel.text = @"Delete";
    } else {
        self.nameField.text = @"";
        self.bdField.text = @"";
        self.doneButton.titleLabel.text = @"Add";
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.kidId >= 0) {
        return NO;
    }
    return YES;
}

-(IBAction)tapDone:(id)sender
{
    
    if (self.kidId >= 0) {
        [[MLApiClient client] deleteKidFromId:kApiClientUserSelf
                                        kidId:self.kidId
                                      success:^(NSHTTPURLResponse *response, id responseJSON) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [self.navigationController popViewControllerAnimated:YES];
                                          });
                                      } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
                                          
                                      }];
    } else {
        [[MLApiClient client] addKidFromId:kApiClientUserSelf
                                      name:self.nameField.text
                                  birthday:self.bdField.text
                                     isBoy:self.typeSwitch.isOn
                                   success:^(NSHTTPURLResponse *response, id responseJSON) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [self.navigationController popViewControllerAnimated:YES];
                                       });
                                   } failure:^(NSHTTPURLResponse *response, id responseJSON, NSError *error) {
                                       NSLog(@" failed to add kid");
                                   }];
    }
  
}

-(IBAction)tapBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
