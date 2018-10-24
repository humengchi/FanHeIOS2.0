//
//  PraiseUserModel.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/11/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface PraiseUserModel : BaseModel

@property (nonatomic, strong) NSNumber *praiseid;
@property (nonatomic, strong) NSNumber *userid;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *headimg;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *timestr;
@property (nonatomic, strong) NSNumber *activityid;
@end
