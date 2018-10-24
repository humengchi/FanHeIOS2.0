//
//  TicketModel.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/10.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BannerModel.h"

@interface TicketModel : BannerModel
@property (nonatomic, strong) NSNumber *remainnum;
@property (nonatomic, strong) NSNumber *ticktid;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSNumber *needcheck;


@property (nonatomic, copy) NSString *remark;
@property (nonatomic, copy) NSString *name;
@end
