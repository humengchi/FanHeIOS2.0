//
//  ApplySettingViewController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/1/3.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseKeyboardViewController.h"

@interface ApplySettingViewController : BaseKeyboardViewController

@property (nonatomic, strong) NSMutableArray *ticketsArray;

@property (nonatomic, strong) NSString *phone;

@property (nonatomic, strong) NSString *applyendtime;

@property (nonatomic, strong) NSString *endtime;

@property (nonatomic, strong) void(^applySetting)(NSMutableArray *ticketsArray, NSString *phone, NSString *applyendtime);


@end
