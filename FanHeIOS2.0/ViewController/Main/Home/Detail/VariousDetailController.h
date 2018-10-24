//
//  VariousDetailController.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/2/27.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

@interface VariousDetailController : BaseViewController

@property (nonatomic, strong) NSNumber *dynamicid;

@property (nonatomic, strong) void(^deleteDynamicDetail)(NSNumber *dynamicid);

@property (nonatomic, strong) void(^attentUser)(BOOL isAttent);

@end
