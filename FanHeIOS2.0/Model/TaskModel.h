//
//  TaskModel.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/8.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface TaskModel : BaseModel

@property (nonatomic, strong) NSNumber *taskid;
@property (nonatomic, strong) NSNumber *award_cb;
@property (nonatomic, strong) NSNumber *status;
@property (nonatomic, strong) NSNumber *extype;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *finish_time;
@property (nonatomic, copy) NSString *icon;

@end
