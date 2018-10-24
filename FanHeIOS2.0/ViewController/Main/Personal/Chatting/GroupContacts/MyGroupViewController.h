//
//  MyGroupViewController.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/8/8.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

@interface MyGroupViewController : BaseViewController

@property(nonatomic, strong) void(^deleteGroup)(NSString *groupId);

@end
