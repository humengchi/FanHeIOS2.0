//
//  ActivityCreateModel.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/1/3.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface ActivityCreateModel : BaseModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *begintime;
@property (nonatomic, copy) NSString *endtime;
@property (nonatomic, copy) NSString *tags;
@property (nonatomic, copy) NSString *intro;
@property (nonatomic, copy) NSString *provincename;
@property (nonatomic, copy) NSString *cityname;
@property (nonatomic, copy) NSString *districtname;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *applyendtime;

@property (nonatomic, strong) NSNumber *userid;
@property (nonatomic, strong) NSNumber *activityid;
@property (nonatomic, strong) NSNumber *lng;
@property (nonatomic, strong) NSNumber *lat;
@property (nonatomic, strong) NSMutableArray *tickets;
@property (nonatomic, strong) NSMutableArray *guests;
@property (nonatomic, strong) UIImage *imagePhoto;

@end
