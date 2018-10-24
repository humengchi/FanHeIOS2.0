//
//  TicketDetailViewController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/6/8.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

@interface TicketDetailViewController : BaseViewController

@property (nonatomic, strong) NSString *ordernum;
@property (nonatomic, strong) NSNumber *status;
@property (nonatomic, copy) NSString *amount;

@end
