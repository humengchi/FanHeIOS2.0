//
//  NotSecoundModel.h
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/21.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface NotSecoundModel : BaseModel
@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *realname;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *createtime;

@property (nonatomic, strong) NSNumber *subjectid;
@property (nonatomic, strong) NSNumber *replycount;
@property (nonatomic, strong) NSNumber *reviewcount;
@property (nonatomic, strong) NSNumber *attentcount;
@property (nonatomic, strong) NSNumber *srcnt;


@property (nonatomic, strong) NSNumber *readcount;
@property (nonatomic, strong) NSNumber *gid;
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, strong) NSNumber *reviewid;
@property (nonatomic, strong) NSNumber *parent;
@property (nonatomic, strong) NSNumber *parentrevid;
@property (nonatomic, strong) NSNumber *mypraisecount;
@property (nonatomic, strong) NSNumber *myreviewcount;

@end
