//
//  UIImageView+Category.m
//  ChannelPlus_iPad
//
//  Created by apple on 15/7/3.
//  Copyright (c) 2015年 hmc. All rights reserved.
//

#import "UIImageView+Category.h"

@implementation UIImageView (Category)

+ (UIImageView*)drawImageViewLine:(CGRect)frame bgColor:(UIColor*)bgColor{
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:frame];
    imgView.backgroundColor = bgColor;
    return imgView;
}

@end
