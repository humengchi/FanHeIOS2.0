//
//  NewMyHomePageController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/11.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

@interface NewMyHomePageController : BaseViewController

@property (nonatomic, strong)  NSNumber *userId;
@property (nonatomic, strong)  ZbarCoffeeModel *zbarModel;
@property (nonatomic, strong)  void(^attentUser)(BOOL isAttent);

@end
