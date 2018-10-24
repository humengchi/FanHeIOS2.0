//
//  BaseTabbarViewController.h
//  JinMai
//
//  Created by 胡梦驰 on 16/3/24.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^CardRequestBlock)(NSNumber *number);//人脉
typedef void(^TFNoteRequestBlock)(NSNumber *number);//大家聊金融
typedef void(^CoffeeRequestBlock)(NSNumber *number);//挂墙咖啡
typedef void(^DynamicRequestBlock)(NSNumber *number);//动态通知

@interface BaseTabbarViewController : BaseViewController

@property (nonatomic, strong) CardRequestBlock cardRequestBlock;
@property (nonatomic, strong) TFNoteRequestBlock tfNoteRequestBlock;
@property (nonatomic, strong) CoffeeRequestBlock coffeeRequestBlock;
@property (nonatomic, strong) DynamicRequestBlock dynamicRequestBlock;

@property (nonatomic, strong) void(^leftButtonClicked)();

- (void)getMessagesCount;

- (void)scanQRCode;

@end
