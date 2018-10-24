//
//  ZbarCoffeeModel.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/18.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface ZbarUserModel : BaseModel

@property (nonatomic, strong)   NSNumber *workyear;
@property (nonatomic, copy)     NSString *workyearstr;
@property (nonatomic, copy)     NSString *realname;
@property (nonatomic, copy)     NSString *image;
@property (nonatomic, copy)     NSString *position;
@property (nonatomic, copy)     NSString *company;
@property (nonatomic, copy)     NSString *city;

@end

@interface ZbarCoffeeModel : BaseModel

@property (nonatomic, strong)   NSNumber *coffid;
@property (nonatomic, strong)   NSNumber *userid;
@property (nonatomic, strong)   NSNumber *getid;
@property (nonatomic, strong)   NSNumber *rst;
@property (nonatomic, strong)   NSNumber *coffcount;

@property (nonatomic, copy)     NSString *headimg;
@property (nonatomic, copy)     NSString *video;
@property (nonatomic, copy)     NSString *remark;
@property (nonatomic, copy)     NSString *code;

@property (nonatomic, strong)   ZbarUserModel *user;

@end
