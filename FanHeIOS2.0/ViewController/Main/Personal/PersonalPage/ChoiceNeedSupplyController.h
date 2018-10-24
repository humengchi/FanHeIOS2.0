//
//  ChoiceNeedSupplyController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/19.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

@interface ChoiceNeedSupplyController : BaseViewController

@property (nonatomic, copy) NSString *limit_times_cn;

@property (nonatomic, strong) void(^publishNeedSupplySuccess)(BOOL isNeed);

@end
