//
//  QuestionSettingController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/2/8.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^QuestionSettingSuccess)();

@interface QuestionSettingController : BaseViewController

@property (nonatomic, strong) QuestionSettingSuccess questionSettingSuccess;

@end
