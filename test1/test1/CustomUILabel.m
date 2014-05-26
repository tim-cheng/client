//
//  CustomUILabel.m
//  test1
//
//  Created by Tim Cheng on 5/26/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "CustomUILabel.h"

@implementation CustomUILabel

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.font = [UIFont fontWithName:@"bariol-regular" size:self.font.pointSize];
}

@end
