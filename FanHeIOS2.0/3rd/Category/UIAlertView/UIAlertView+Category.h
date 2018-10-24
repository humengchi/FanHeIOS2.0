//
//  UIAlertView+Category.h
//  ChannelPlus
//
//  Created by Peter on 15/1/6.
//  Copyright (c) 2015年 Peter. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ALERT_DEFAULT_TITLE  @"温馨提示"

@interface UIAlertView (Category)

+ (void)showMessage:(NSString *)message;
+ (void)showMessage:(NSString *)title message:(NSString *)message;
@end
