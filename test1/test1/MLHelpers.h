//
//  MLHelpers.h
//  test1
//
//  Created by Tim Cheng on 5/26/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#ifndef test1_MLHelpers_h
#define test1_MLHelpers_h


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define MLColor UIColorFromRGB(0xe24f64)
#define MLColorBrown UIColorFromRGB(0x625959)

#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)? NO : YES)

#define MLDefaultPost @"Ask or share something"

#endif
