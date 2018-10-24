//
//  UILocalNotification+Category.h
//  ChannelPlus_iPad
//
//  Created by apple on 15/8/26.
//  Copyright (c) 2015年 hmc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILocalNotification (Category)

+(BOOL)addNotificationWidthUUID:(NSString*)uuid alertTime:(NSDate*)alertTime message:(NSString*)message;

+(BOOL)cleanAllUnUploadNotifications;

+(void)cleanAllNotifications;

@end
