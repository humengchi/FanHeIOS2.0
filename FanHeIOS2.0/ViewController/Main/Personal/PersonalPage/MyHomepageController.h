//
//  MyHomepageController.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/3.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyHomepageController : BaseViewController

@property (nonatomic, strong)  ZbarCoffeeModel *zbarModel;
@property (nonatomic, assign)  BOOL stayTapy;
@property (nonatomic, strong)  NSNumber *userID;
@property (nonatomic, strong)  void(^attentUser)(BOOL isAttent);

@end
