//
//  DynamicKeyWordController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/2/23.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

@interface DynamicKeyWordController : BaseViewController

@property (nonatomic, strong) void (^DynamicKeyWord)(NSString* keyWord);

@end