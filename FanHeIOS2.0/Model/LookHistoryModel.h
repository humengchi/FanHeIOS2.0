//
//  LookHistoryModel.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/10/28.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface LookHistoryModel : BaseModel
@property (nonatomic, strong)   NSNumber *userid;
@property (nonatomic, strong)   NSNumber *usertype;
@property (nonatomic, strong)   NSNumber *othericon;
@property (nonatomic, strong)   NSNumber *hasValidUser;
@property (nonatomic, copy)     NSString *realname;
@property (nonatomic, copy)     NSString *company;
@property (nonatomic, copy)     NSString *position;
@property (nonatomic, copy)     NSString *image;
@property (nonatomic, copy)     NSString *visitedtime;
@property (nonatomic, copy)     NSString *relation;

//活动
@property (nonatomic, strong)   NSNumber *applyid;
@property (nonatomic, strong)   NSNumber *price;
@property (nonatomic, copy)     NSString *phone;
@property (nonatomic, copy)     NSString *memo;
@property (nonatomic, copy)     NSString *created_at;
@property (nonatomic, copy)     NSString *ordernum;


@property (nonatomic, strong)   NSNumber *status;
@property (nonatomic, copy)     NSString *stat;
@property (nonatomic, strong)   NSNumber *ticketnum;
@property (nonatomic, strong)   NSString *remark;
@property (nonatomic, strong)   NSNumber *ticketid;
@property (nonatomic, strong)   NSString *ticketname;
@property (nonatomic, strong)   NSMutableArray *applyusers;


@end
