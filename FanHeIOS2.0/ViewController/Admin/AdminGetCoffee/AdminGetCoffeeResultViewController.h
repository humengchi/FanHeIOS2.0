//
//  AdminGetCoffeeResultViewController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/9/6.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

//类型
typedef NS_ENUM(NSInteger, Result_Type) {
    Result_Type_GetCoffee,
    Result_Type_Callback,
    Result_Type_HangCoffee,
};

@interface AdminGetCoffeeResultViewController : BaseViewController

@property (nonatomic, assign) Result_Type resultType;

@end
