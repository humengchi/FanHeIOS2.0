//
//  AdminGetCoffeeModel.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/9/6.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface AdminGetCoffeeModel : BaseModel

@property (nonatomic, copy) NSString    *code;
@property (nonatomic, copy) NSString    *getname;
@property (nonatomic, copy) NSString    *company;
@property (nonatomic, copy) NSString    *position;
@property (nonatomic, copy) NSString    *msg;

@property (nonatomic, strong) NSNumber  *coffid;
@property (nonatomic, strong) NSNumber  *rst;

@end
