//
//  NeedModel.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/14.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface NeedModel : BaseModel

@property (nonatomic, strong) NSNumber *gxid;
@property (nonatomic, strong) NSNumber *dynamic_id;
@property (nonatomic, copy)   NSString *title;
@property (nonatomic, copy)   NSString *intro;
@property (nonatomic, copy)   NSString *created_at;
@property (nonatomic, strong) NSArray  *tags;
@property (nonatomic, strong) NSNumber *count;

@end
