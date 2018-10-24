//
//  CommentPersonController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/18.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseKeyboardViewController.h"

@interface CommentPersonController : BaseKeyboardViewController

@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, copy) NSString *realname;

@property (nonatomic, strong) void(^commentSuccess)();

@end
