//
//  UILocalNotification+Category.m
//  ChannelPlus_iPad
//
//  Created by apple on 15/8/26.
//  Copyright (c) 2015年 hmc. All rights reserved.
//

#import "UILocalNotification+Category.h"

@implementation UILocalNotification (Category)

+(BOOL)addNotificationWidthUUID:(NSString*)uuid alertTime:(NSDate*)alertTime message:(NSString*)message {
    BOOL retVal = NO;
    @try {
        UILocalNotification *notification= [[UILocalNotification alloc] init];
        if (notification != nil) {
            notification.fireDate = alertTime;
            notification.repeatInterval = 0;
            notification.timeZone = [NSTimeZone defaultTimeZone];
//            notification.applicationIconBadgeNumber = badgeNumber;
            notification.soundName= UILocalNotificationDefaultSoundName;
            notification.alertBody = message;
            // action button caption
            notification.alertAction = @"OK";
            //是否显示额外的按钮，为no时alertAction消失
            //notification.hasAction = NO;
            NSDictionary *infoDict = [NSDictionary dictionaryWithObject:uuid forKey:@"key"];
            notification.userInfo = infoDict;
            
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
//            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {// 本地通知无效
//                [NSThread sleepForTimeInterval:2];
//            }
        }
        retVal = YES;
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        retVal = NO;
    }
    @finally {
        
    }
    return retVal;
}

+(BOOL)cleanAllUnUploadNotifications {
    BOOL retVal = NO;
    @try {
        NSArray *localArr = [[UIApplication sharedApplication] scheduledLocalNotifications];
        UILocalNotification *localNoti = nil;
        if (localArr.count > 0) {
            for (UILocalNotification *noti in localArr) {
                NSDictionary *dict = noti.userInfo;
                if (dict) {
                    NSString *currentUID = [dict objectForKey:@"key"];
                    if ([currentUID hasSuffix:@"_upload"]) {
                        if (localNoti){
                            localNoti = nil;
                        }
                        localNoti = noti;
                        if (localNoti) {
                            //不推送 取消推送
                            [[UIApplication sharedApplication] cancelLocalNotification:localNoti];
                        }
                    }
                }
            }
        }
        retVal = YES;
    }
    @catch (NSException *exception) {
        retVal = NO;
    }
    @finally {
        
    }
    return retVal;
}

+(void)cleanAllNotifications {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}
@end
