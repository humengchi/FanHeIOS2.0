//
//  PublishNeedSupplyController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/19.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseKeyboardViewController.h"

@interface PublishNeedSupplyController : BaseKeyboardViewController

@property (nonatomic, assign) BOOL isNeed;

@property (nonatomic, strong) void(^publishNeedSupplySuccess)(BOOL isNeed);

@end
