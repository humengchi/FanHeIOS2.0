//
//  MyHomeTopicModel.h
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/22.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface MyHomeTopicModel : BaseModel
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *created_at;

@property (nonatomic, strong) NSNumber *sreplycount;
@property (nonatomic, strong) NSNumber *sattentcount;
@property (nonatomic, strong) NSNumber *sreviewcount;
@property (nonatomic, strong) NSNumber *sid;

@property (nonatomic, strong) NSNumber *srid;
@property (nonatomic, strong) NSNumber *srpraisecount;

@property (nonatomic, strong) NSNumber *srreviewcount;
@end
