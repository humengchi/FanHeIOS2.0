//
//  GetWallCoffeeDetailViewController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/26.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^ReplySuccess)(NSString *revert);

@interface GetWallCoffeeDetailViewController : BaseViewController

@property (nonatomic, strong) NSNumber *coffeegetid;
@property (nonatomic, assign) BOOL  isMygetCoffee;
@property (nonatomic, strong) NSNumber *type; //是否已读消息

@property (nonatomic, strong) ReplySuccess replySuccess;

@end
