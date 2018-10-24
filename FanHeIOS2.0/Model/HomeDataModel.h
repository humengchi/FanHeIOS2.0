//
//  HomeDataModel.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/10/31.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface ActivityModel : BaseModel

@property (nonatomic, strong) NSNumber *activityid;

@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *organizer;
@property (nonatomic, copy) NSString *starttime;
@property (nonatomic, copy) NSString *startmonth;
@property (nonatomic, copy) NSString *startday;
@property (nonatomic, copy) NSString *url;

@end

@interface DJTalkModel : BaseModel

@property (nonatomic, strong) NSNumber *postid;

@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) CGFloat cellHeight;

@end

@interface HomeTableDataModel : BaseModel

@property (nonatomic, strong) NSNumber *type;

@property (nonatomic, strong) NSMutableArray *array;

@property (nonatomic, copy) NSString *title;

@end

@interface HomeDataModel : BaseModel

@property (nonatomic, strong) NSMutableArray *tt;
@property (nonatomic, strong) NSMutableArray *activity;
@property (nonatomic, strong) NSMutableArray *djtalk;
@property (nonatomic, strong) NSMutableArray *hopeme;
@property (nonatomic, strong) NSMutableArray *hotpeople;
@property (nonatomic, strong) NSMutableArray *mayknowpeople;
@property (nonatomic, strong) NSMutableArray *seeme;

@property (nonatomic, strong) NSMutableArray *tableDataArray;

@end
