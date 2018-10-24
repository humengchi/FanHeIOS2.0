//
//  MyTopicModel.h
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/20.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"
#import "NotSecoundModel.h"
@interface MyTopicModel : BaseModel
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *realname;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *createtime;
@property (nonatomic, copy) NSString *mycontent;
@property (nonatomic, strong) NSNumber *post_id;
@property (nonatomic, strong) NSNumber *reviewid;
@property (nonatomic, strong) NSNumber *userid;
@property (nonatomic, strong) NSNumber *usertype;
@property (nonatomic, strong) NSNumber *subjectid;
@property (nonatomic, strong) NSNumber *replycount;
@property (nonatomic, strong) NSNumber *reviewcount;
@property (nonatomic, strong) NSNumber *attentcount;
@property (nonatomic, strong) NSNumber *srcnt;
@property (nonatomic, strong) NSNumber *status;
@property (nonatomic, strong) NSNumber *ishidden;
@property (nonatomic, strong) NSNumber *readcount;
@property (nonatomic, strong) NSNumber *gid;
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, strong) NSNumber *review_id;
@property (nonatomic, strong) NSNumber *parent;
@property (nonatomic, strong) NSNumber *parentrevid;
@property (nonatomic, strong) NSNumber *mypraisecount;
@property (nonatomic, strong) NSNumber *activityid;
@property (nonatomic, strong) NSNumber *myreviewcount;
@property (nonatomic, strong) NSNumber *lasttime;

@property (nonatomic, copy) NSString *created_at;

@property (nonatomic, strong) NSNumber *sreplycount;
@property (nonatomic, strong) NSNumber *sattentcount;
@property (nonatomic, strong) NSNumber *sreviewcount;
@property (nonatomic, strong) NSNumber *sid;
@property (nonatomic, strong) NSNumber *subject_id;
@property (nonatomic, strong) NSNumber *subject_review_id;
@property (nonatomic, strong) NSNumber *srid;
@property (nonatomic, strong) NSNumber *srpraisecount;

@property (nonatomic, strong) NSNumber *srreviewcount;
@property (nonatomic, strong)  NotSecoundModel *model;

@property (nonatomic, assign) BOOL isViewPoint;
@property (nonatomic, assign) CGFloat cellHeight;

@end
