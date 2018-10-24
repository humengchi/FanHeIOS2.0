//
//  NeedSupplyListController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/17.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

@interface NeedSupplyListController : BaseViewController
@property (nonatomic, strong) NSString *chartRoomId;
@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, assign) BOOL isNeed;
@property (nonatomic, assign) BOOL isShare;
@property (nonatomic) EMChatType chatType;
@property (nonatomic, strong) void(^needOrSupplyChange)();

@end
