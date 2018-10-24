//
//  TopicDetailModel.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/15.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface TopicDetailModel : BaseModel

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *mergetitle;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *updated_at;
@property (nonatomic, copy) NSString *explain;
@property (nonatomic, copy) NSString *realname;
@property (nonatomic, copy) NSString *image;


@property (nonatomic, strong) NSNumber *subjectid;
@property (nonatomic, strong) NSNumber *user_id;
@property (nonatomic, strong) NSNumber *replycount;
@property (nonatomic, strong) NSNumber *attentcount;
@property (nonatomic, strong) NSNumber *reviewcount;
@property (nonatomic, strong) NSNumber *status;
@property (nonatomic, strong) NSNumber *isattent;
@property (nonatomic, strong) NSNumber *frdintalkcnt;
@property (nonatomic, strong) NSNumber *mergeto;

@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) NSArray *frdintalk;

@end
