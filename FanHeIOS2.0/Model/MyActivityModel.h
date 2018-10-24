//
//  MyActivityModel.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/4.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface InfoFieldModel : BaseModel

@property (nonatomic, copy) NSString *infoname;
@property (nonatomic, copy) NSString *infovalue;

@property (nonatomic, strong) NSNumber *infoid;
@property (nonatomic, strong) NSNumber *infotype;

- (void)copy:(InfoFieldModel*)model;

@end

@interface MyActivityModel : BaseModel
@property (nonatomic, copy) NSString * online_info;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *starttime;
@property (nonatomic, copy) NSString *endtime;
@property (nonatomic, copy) NSString *provincename;
@property (nonatomic, copy) NSString *cityname;
@property (nonatomic, copy) NSString *districtname;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *addresstype;
@property (nonatomic, copy) NSString *timestr;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *contents;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *applystr;
@property (nonatomic, copy) NSString *placeimg;
@property (nonatomic, copy) NSString *placeurl;
@property (nonatomic, copy) NSString *subcontent;
@property (nonatomic, copy) NSString *guestname;
@property (nonatomic, copy) NSString *livebroadcast_url;
@property (nonatomic, copy) NSString *addr;
@property (nonatomic, copy) NSString *livebroadcast_start;


@property (nonatomic, strong) NSNumber *postid;
@property (nonatomic, strong) NSNumber *status;
@property (nonatomic, strong) NSNumber *asknum;
@property (nonatomic, strong) NSNumber *lat;
@property (nonatomic, strong) NSNumber *lng;
@property (nonatomic, strong) NSNumber *district;
@property (nonatomic, strong) NSNumber *city;
@property (nonatomic, strong) NSNumber *province;
@property (nonatomic, strong) NSNumber *activityid;
@property (nonatomic, strong) NSNumber *readcount;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) NSArray *tickets;
@property (nonatomic, strong) NSMutableArray *infofields;
@property (nonatomic, assign)  CGFloat cellHeight;
@property (nonatomic, strong) NSNumber *feetype;//1-收费，3-免费

//我发布的活动
@property (nonatomic, copy) NSString *applyendtime;
@property (nonatomic, copy) NSString *edittime;

@property (nonatomic, strong) NSNumber *applynum;
@property (nonatomic, strong) NSNumber *newapplynum;
@property (nonatomic, strong) NSNumber *newasknum;
@property (nonatomic, strong) NSNumber *canchange;
@property (nonatomic, copy) NSString *canapply;

@end
