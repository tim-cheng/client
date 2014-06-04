//
//  CustomUITextField.m
//  test1
//
//  Created by Tim Cheng on 5/26/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "CustomUITextField.h"

@implementation CustomUITextField

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.font = [UIFont fontWithName:@"bariol-regular" size:self.font.pointSize];
}

@end
