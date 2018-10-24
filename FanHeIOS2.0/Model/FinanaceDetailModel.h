//
//  FinanaceDetailModel.h
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface FinanaceDetailModel : BaseModel
@property (nonatomic, copy) NSString *headimg;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *publish_at;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *company;
@property (nonatomic, copy) NSString *position;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *realname;
@property (nonatomic, copy) NSDictionary *replyto;
@property (nonatomic, copy) NSString *replyname;
@property (nonatomic, copy) NSString *subcontent;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *timestr;
@property (nonatomic, copy) NSString *cityname;
@property (nonatomic, copy) NSString *districtname;
@property (nonatomic, copy) NSString *provincename;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, strong) NSNumber *category;
@property (nonatomic, strong) NSNumber *replyid;
@property (nonatomic, strong) NSNumber *userid;
@property (nonatomic, strong) NSNumber *reviewid;
@property (nonatomic, strong) NSNumber *postid;
@property (nonatomic, strong) NSNumber *usertype;
@property (nonatomic, strong) NSNumber *praisecount;
@property (nonatomic, strong) NSNumber *postuserid;
@property (nonatomic, strong) NSNumber *othericon;
@property (nonatomic, strong) NSNumber *isattention;
@property (nonatomic, strong) NSNumber *ispraise;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) NSArray *relatepost;
@property (nonatomic, strong) NSNumber *reviewcount;
@property (nonatomic, strong) NSNumber *activityid;
@property (nonatomic, assign) BOOL hotRateStart;
@property (nonatomic, strong) PraiseUserModel *model;

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *value;

@end
