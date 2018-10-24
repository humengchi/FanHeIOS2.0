//
//  TicketPaymentController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/6/8.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

@interface TicketPaymentController : BaseViewController

@property (nonatomic, strong) MyActivityModel *activityModel;
@property (nonatomic, strong) TicketModel *ticketModel;
@property (nonatomic, assign) NSInteger ticketNum;
@property (nonatomic, strong) NSString *ordernum;
@property (nonatomic, strong) NSDate *currentDate;

@end
