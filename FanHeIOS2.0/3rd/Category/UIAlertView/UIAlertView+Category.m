//
//  UIAlertView+Category.m
//  ChannelPlus
//
//  Created by Peter on 15/1/6.
//  Copyright (c) 2015年 Peter. All rights reserved.
//

#import "UIAlertView+Category.h"


@implementation UIAlertView (Category)


+ (void)showMessage:(NSString *)message
{
    [UIAlertView showMessage:ALERT_DEFAULT_TITLE message:message];
}

+ (void)showMessage:(NSString *)title message:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
}

@end
