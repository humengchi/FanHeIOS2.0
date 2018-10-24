//
//  ContactsModel.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/9.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface ContactsModel : BaseModel
@property (nonatomic, strong)   NSNumber *rid;
@property (nonatomic, strong)   NSNumber *userid;
@property (nonatomic, strong)   NSNumber *hasValidUser;
@property (nonatomic, strong)   NSNumber *attentionhenum;
@property (nonatomic, strong)   NSNumber *friendcnt;
@property (nonatomic, strong)   NSNumber *attentedcnt;
@property (nonatomic, strong)   NSNumber *videoplaycount;
@property (nonatomic, strong)   NSNumber *invitenum;
@property (nonatomic, strong)   NSNumber *getednum;
@property (nonatomic, strong)   NSNumber *cardrequestid;
@property (nonatomic, strong)   NSNumber *workyear;
@property (nonatomic, strong)   NSNumber *othericon;// 1专访
@property (nonatomic, strong)   NSNumber *usertype;// 9嘉宾用户

@property (nonatomic, copy)     NSString *image;
@property (nonatomic, copy)     NSString *realname;
@property (nonatomic, copy)     NSString *city;
@property (nonatomic, copy)     NSString *company;
@property (nonatomic, copy)     NSString *position;
@property (nonatomic, copy)     NSString *workyearstr;
@property (nonatomic, copy)     NSString *video;
@property (nonatomic, copy)     NSString *reason;
@property (nonatomic, copy)     NSString *audio;
@property (nonatomic, copy)     NSString *mystate;

@property (nonatomic, strong)   NSArray  *goodjob;
@property (nonatomic, strong)   NSNumber *type;
@property (nonatomic, strong)   NSNumber *count;
@property (nonatomic, strong)   NSMutableArray  *userArray;
@property (nonatomic, assign)   CGFloat cellHeight;

//新的人脉添加字段
@property (nonatomic, strong)   NSNumber *samefriend;
@property (nonatomic, copy)     NSString *relation;
@property (nonatomic, copy)     NSString *need;
@property (nonatomic, copy)     NSString *supply;
@property (nonatomic, strong)   NSNumber *hasaskcheck;

@property (nonatomic, strong)   NSNumber *invite; //是否被邀请过

@end
