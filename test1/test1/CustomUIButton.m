//
//  CustomUIButton.m
//  test1
//
//  Created by Tim Cheng on 5/26/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "CustomUIButton.h"

@implementation CustomUIButton

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.titleLabel.font = [UIFont fontWithName:@"bariol-regular" size:self.titleLabel.font.pointSize];
}

@end
