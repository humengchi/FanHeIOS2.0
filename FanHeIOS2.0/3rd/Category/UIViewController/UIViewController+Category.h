//
//  UIViewController+Category.h
//  ChannelPlus
//
//  Created by Peter on 14/12/20.
//  Copyright (c) 2014年 Peter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Category)
- (UIButton *)intTwoNavBarRight:(CGRect)rect oneImageName:(NSString *)oneImageName oneButtonName:(NSString *)oneButtonName twoImageName:(NSString *)twoImageName twoButtonName:(NSString *)twoButtonName;


- (void)oneRigthUpAction:(UIButton *)btn;
- (void)twoRigthUpAction:(UIButton *)btn;
- (UIButton *)intNavBarRight:(CGRect)rect imageName:(NSString *)imageName buttonName:(NSString *)buttonName;

- (void)initSpaceLeftNavBar;

- (void)initDefaultLeftNavbar;

- (void)newThreadForAvoidButtonRepeatClick:(id)sender;

- (void)initHomeBarButtonItem;

- (UIButton *)intNavBarButtonItem:(BOOL)right frame:(CGRect)rect imageName:(NSString *)imageName buttonName:(NSString *)buttonName;

- (NSString *)getImagePath:(UIImage *)image;

@end
