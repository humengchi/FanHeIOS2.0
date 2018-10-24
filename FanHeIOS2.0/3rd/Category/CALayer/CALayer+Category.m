//
//  CALayer+Category.m
//  ChannelPlus
//
//  Created by Peter on 15/1/17.
//  Copyright (c) 2015年 Peter. All rights reserved.
//

#import "CALayer+Category.h"

@implementation CALayer (Category)

+ (void)updateControlLayer:(CALayer *)layer radius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(CGColorRef)borderColor{
    layer.cornerRadius = radius;
    layer.borderWidth = borderWidth;
    layer.borderColor = borderColor;
    layer.masksToBounds = YES;
}



@end
