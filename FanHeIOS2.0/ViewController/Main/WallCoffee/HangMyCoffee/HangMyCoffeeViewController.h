//
//  HangMyCoffeeViewController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/30.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseKeyboardViewController.h"

typedef void(^HangCoffeeSuccess)();

@interface HangMyCoffeeViewController : BaseKeyboardViewController

@property (nonatomic, copy) NSString    *imageUrl;
@property (nonatomic, copy) NSString    *videoUrl;

@property (nonatomic, strong) HangCoffeeSuccess hangCoffeeSuccess;

@end
