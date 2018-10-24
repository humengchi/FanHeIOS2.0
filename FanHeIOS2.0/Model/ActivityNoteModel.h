//
//  ActivityNoteModel.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/1/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface ActivityNoteModel : BaseModel

@property (nonatomic, strong) NSNumber *activityid;
@property (nonatomic, strong) NSNumber *ask_id;
@property (nonatomic, strong) NSNumber *isread;
@property (nonatomic, strong) NSNumber *status;
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, strong) NSNumber *user_id;

@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *reason;
@property (nonatomic, copy) NSString *starttime;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *begintime;
@property (nonatomic, copy) NSString *endtime;

@end
