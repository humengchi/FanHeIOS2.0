//
//  InterestBusinessController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/2/22.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

@interface InterestBusinessController : BaseViewController

@property (nonatomic, assign) BOOL isShowBack;

@property (nonatomic, strong) void(^saveInterestBusiness)();

@end
