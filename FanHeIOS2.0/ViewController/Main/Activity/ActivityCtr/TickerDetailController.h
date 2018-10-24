//
//  TickerDetailController.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/11.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

@interface TickerDetailController : BaseViewController
@property (nonatomic ,strong) TicketModel *model;
//分享活动给好友
@property (strong, nonatomic) MyActivityModel *actModel;
@end
