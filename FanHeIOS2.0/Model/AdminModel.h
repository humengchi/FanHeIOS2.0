//
//  AdminModel.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/9/7.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface AdminModel : BaseModel


@property (nonatomic, strong)   NSNumber *userid;

@property (nonatomic, copy)     NSString *name;
@property (nonatomic, copy)     NSString *account;
@property (nonatomic, copy)     NSString *store;

@end
