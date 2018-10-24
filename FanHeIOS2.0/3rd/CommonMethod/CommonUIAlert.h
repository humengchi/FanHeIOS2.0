//
//  CommonUIAlert.h
//  ChannelPlus
//
//  Created by apple on 15/11/16.
//  Copyright (c) 2015年 Peter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonUIAlert : UIViewController<UIAlertViewDelegate>

- (void)showCommonAlertView:(UIViewController *)viewController title:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle cancle:(void (^)())cancle confirm:(void (^)())confirm;

- (void)showCommonAlertView:(UIViewController *)viewController message:(NSString *)message;

@end