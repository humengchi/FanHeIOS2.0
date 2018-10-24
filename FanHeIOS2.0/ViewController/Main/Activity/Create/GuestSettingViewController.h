//
//  GuestSettingViewController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/1/3.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseKeyboardViewController.h"

@interface GuestSettingViewController : BaseKeyboardViewController

@property (nonatomic, strong) NSMutableArray *guestsArray;

@property (nonatomic, strong) void(^guestSetting)(NSMutableArray *guestsArray);

@end
