//
//  ActivityOrderModel.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/6/16.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface ActivityOrderModel : BaseModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *starttime;
@property (nonatomic, copy) NSString *endtime;
@property (nonatomic, copy) NSString *cityname;
@property (nonatomic, copy) NSString *districtname;
@property (nonatomic, copy) NSString *ticketname;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *amount;
@property (nonatomic, copy) NSString *payamount;
@property (nonatomic, copy) NSString *timestr;
@property (nonatomic, copy) NSString *stat;
@property (nonatomic, copy) NSString *ordernum;
@property (nonatomic, copy) NSString *remark;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *subcontent;

@property (nonatomic, strong) NSNumber *ticketnum;
@property (nonatomic, strong) NSNumber *status;

@property (nonatomic, strong) NSNumber *activityid;
@property (nonatomic, strong) NSNumber *needcheck;

@end
