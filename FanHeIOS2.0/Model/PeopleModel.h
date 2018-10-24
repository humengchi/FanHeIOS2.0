//
//  PeopleModel.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/17.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface PeopleModel : BaseModel
@property (nonatomic, strong)   NSNumber *count;

@property (nonatomic, strong)   NSNumber *friendcount;
@property (nonatomic, copy)     NSArray *photo;
@end
