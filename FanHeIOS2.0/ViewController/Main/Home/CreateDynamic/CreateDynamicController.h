//
//  CreateDynamicController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/2/23.
//  Copyright © 2017年 胡梦驰. All rights reserved.

#import <UIKit/UIKit.h>

typedef void(^CreateDynamicSuccess)(DynamicModel *model);

@interface CreateDynamicController : UIViewController

@property (nonatomic, strong) CreateDynamicSuccess createDynamicSuccess;


@end

