//
//  TicketPersonInfoModel.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/6/16.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface TicketPersonInfoModel : BaseModel

@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *remark;
@property (nonatomic, copy) NSString *ticketname;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *dcnum;

@end
