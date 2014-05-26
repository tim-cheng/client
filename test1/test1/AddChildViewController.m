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
@property (strong, nonatomic) IBOutlet UIButton *boyButton;
@property (strong, nonatomic) IBOutlet UIButton *girlButton;

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) NSDateFormatter *bdFormat;

-(IBAction)tapDone:(id)sender;
-(IBAction)tapBack:(id)sender;

@end
@implementation AddChildViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.bdFormat = [[NSDateFormatter alloc] init];
    self.bdFormat.dateFormat = @"yyyy'-'MM'-'dd";
    
    self.nameField.delegate = self;
    if (self.kidId >= 0) {
        self.nameField.text = self.kidName;
        self.doneButton.titleLabel.text = @"Delete";
        self.boyButton.selected = self.kidIsBoy;
        self.girlButton.selected = !self.kidIsBoy;
        self.datePicker.date = [self.bdFormat dateFromString:self.kidBirthday];
    } else {
        self.nameField.text = @"";
        self.doneButton.titleLabel.text = @"Add";
        self.boyButton.selected = YES;
        self.girlButton.selected = NO;
        NSLog(@"!!!I am here..");
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
                                  birthday:[self.bdFormat stringFromDate:self.datePicker.date]
                                     isBoy:self.boyButton.selected
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

-(IBAction)tapBoy:(id)sender
{
    self.boyButton.selected = YES;
    self.girlButton.selected = NO;
}

-(IBAction)tapGirl:(id)sender
{
    self.boyButton.selected = NO;
    self.girlButton.selected = YES;
}

@end
