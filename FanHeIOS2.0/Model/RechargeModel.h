//
//  RechargeModel.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface RechargeModel : BaseModel

@property (nonatomic, copy) NSString *num;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSNumber *cb;
@property (nonatomic, strong) NSNumber *gift;

@end
