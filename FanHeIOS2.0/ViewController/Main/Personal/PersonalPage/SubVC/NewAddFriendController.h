//
//  NewAddFriendController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/2/8.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseKeyboardViewController.h"

typedef void(^ExchangeSuccess) (BOOL success);

@interface NewAddFriendController : BaseKeyboardViewController

@property (nonatomic, strong)  NSString *realname;
@property (nonatomic, strong)  NSString *phone;
@property (nonatomic, strong)  NSNumber *userID;
@property (nonatomic, strong) ExchangeSuccess exchangeSuccess;

@end
