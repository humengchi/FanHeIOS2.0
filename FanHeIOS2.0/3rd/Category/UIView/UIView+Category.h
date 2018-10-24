//
//  UIView+Category.h
//  ChannelPlus
//
//  Created by Mobilizer on 15/5/14.
//  Copyright (c) 2015年 Peter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Category)

- (void)shakeByRotation:(int)repeatCount;
- (void)shakeByTranslation:(int)repeatCount;

- (UIView *)subviewWithTag:(NSInteger)tag;

- (UIViewController *)viewController;

@end
