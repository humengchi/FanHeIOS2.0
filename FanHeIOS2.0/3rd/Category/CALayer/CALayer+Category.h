//
//  CALayer+Category.h
//  ChannelPlus
//
//  Created by Peter on 15/1/17.
//  Copyright (c) 2015年 Peter. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (Category)

+ (void)updateControlLayer:(CALayer *)layer radius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(CGColorRef)borderColor;

@end
