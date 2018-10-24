//
//  SearchModel.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/1/20.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface SearchModel : BaseModel

@property (nonatomic, strong) NSNumber *rid;
@property (nonatomic, strong) NSNumber *othericon;
@property (nonatomic, strong) NSNumber *usertype;
@property (nonatomic, strong) NSNumber *hasValidUser;
@property (nonatomic, strong) NSNumber *status;

@property (nonatomic, strong) NSNumber *attentcount;
@property (nonatomic, strong) NSNumber *replycount;
@property (nonatomic, strong) NSNumber *reviewcount;

@property (nonatomic, strong) NSNumber *addresstype;

@property (nonatomic, strong) NSNumber *readcount;

@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) NSArray *tags;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *company;
@property (nonatomic, copy) NSString *position;
@property (nonatomic, copy) NSString *image;

@property (nonatomic, copy) NSString *starttime;
@property (nonatomic, copy) NSString *endtime;
@property (nonatomic, copy) NSString *provincename;
@property (nonatomic, copy) NSString *cityname;
@property (nonatomic, copy) NSString *districtname;
@property (nonatomic, copy) NSString *timestr;
@property (nonatomic, copy) NSString *guestname;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *relation;
@property (nonatomic, strong) NSNumber *samefriend;

@end
