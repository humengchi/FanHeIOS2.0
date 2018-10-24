//
//  CardScanModel.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/14.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface CardGroupModel : BaseModel

@property (nonatomic, copy) NSString *groupname;

@property (nonatomic, strong) NSNumber *groupid;
@property (nonatomic, strong) NSNumber *cnt;

@property (nonatomic, strong) NSNumber *isSelected;

@end

@interface CardScanModel : BaseModel

@property (nonatomic, strong) NSMutableArray *position;
@property (nonatomic, strong) NSMutableArray *company;
@property (nonatomic, strong) NSMutableArray *address;
@property (nonatomic, strong) NSMutableArray *jobphone;
@property (nonatomic, strong) NSMutableArray *fax;
@property (nonatomic, strong) NSMutableArray *email;
@property (nonatomic, strong) NSMutableArray *website;
@property (nonatomic, strong) NSMutableArray *qq;
@property (nonatomic, strong) NSMutableArray *wx;
@property (nonatomic, strong) NSMutableArray *groups;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *letter;
@property (nonatomic, copy) NSString *zipcode;
@property (nonatomic, copy) NSString *imgurl;
@property (nonatomic, copy) NSString *birthday;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *updated_at;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *remark;

@property (nonatomic, strong) NSNumber *btn;
@property (nonatomic, strong) NSNumber *source;
@property (nonatomic, strong) NSNumber *cardId;
@property (nonatomic, strong) NSNumber *ismycard;
@property (nonatomic, strong) NSNumber *user_id;
@property (nonatomic, strong) NSNumber *otherid;
@end
