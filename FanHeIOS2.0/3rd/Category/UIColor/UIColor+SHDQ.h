//
//  UIColor+SHDQ.h
//  SHDQ
//
//  Created by Peter on 14-9-11.
//  Copyright (c) 2014年 com.shdq. All rights reserved.
//

#import <UIKit/UIKit.h>

#define HEX_COLOR(x)    [UIColor colorWithHexString1:(x)]
#define WHITE_COLOR     [UIColor whiteColor]
#define BLACK_COLOR     [UIColor blackColor]


#define RANDOM_COLOR [UIColor colorWithRed:arc4random() % 255 / 255.0 green:arc4random() % 255 / 255.0 blue:arc4random() % 255 / 255.0 alpha:1]
#define TRANSPARENT_COLOR         [UIColor clearColor]


@interface UIColor (SHDQ)
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;
#pragma mark - 颜色转换 IOS中十六进制的颜色转换为UIColor
+ (UIColor *)colorWithHexString1: (NSString *)color;
@end
