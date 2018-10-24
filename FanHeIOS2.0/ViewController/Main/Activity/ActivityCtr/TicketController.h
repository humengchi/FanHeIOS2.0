//
//  TicketController.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/10.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

@interface TicketController : BaseViewController
@property (nonatomic,strong)NSArray *tickerArray;
//分享活动给好友
@property (strong, nonatomic) MyActivityModel *actModel;
@end
