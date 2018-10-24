//
//  TaMessageModel.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"
@interface TaMessageModel : BaseModel
@property (nonatomic, strong)   NSNumber *isattention;
@property (nonatomic, strong)   NSNumber *iscoffee;
@property (nonatomic, strong)   NSNumber *isfriend;
@property (nonatomic, strong)   NSNumber *attentionhenum;
@property (nonatomic, strong)   NSNumber *comfriendnum;
@property (nonatomic, strong)   NSNumber *hisattentionnum;
@property (nonatomic, strong)   NSNumber *friendnum;
@property (nonatomic, strong)   NSNumber *hasValidUser;
@property (nonatomic, strong)   NSNumber *workyear;
@property (nonatomic, strong)   NSNumber *usertype;
@property (nonatomic, strong)   NSNumber *canviewphone;
@property (nonatomic, copy)     NSString *industry;
@property (nonatomic, copy)     NSString *workyearstr;
@property (nonatomic, copy)     NSString *image;
@property (nonatomic, copy)     NSString *email;
@property (nonatomic, copy)     NSString *phone;
@property (nonatomic, copy)     NSString *position;
@property (nonatomic, copy)     NSString *company;
@property (nonatomic, copy)     NSString *weixin;
@property (nonatomic, copy)     NSString *mystate;

@property (nonatomic, copy)     NSString *realname;
@property (nonatomic, copy)     NSString *video;
@property (nonatomic, copy)     NSString *remark;
@property (nonatomic, copy)     NSString *city;
@property (nonatomic, copy)     NSArray *business;
@property (nonatomic, copy)     NSArray *cofferArray;
@property (nonatomic, copy)     NSArray *taPeopleArray;


@property (nonatomic, assign)   BOOL isMyHomePage;//虚拟字段，是否时我的主页

@end
