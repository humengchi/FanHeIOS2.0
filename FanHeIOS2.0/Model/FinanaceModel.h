//
//  FinanaceModel.h
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"
#import "PushTicpsmodle.h"
@interface FinanaceModel : BaseModel
@property (nonatomic, copy) NSString *photo;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *createtime;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *realname;
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, strong) NSNumber *reviewcount;
@property (nonatomic, strong) NSNumber *replycount;
@property (nonatomic, strong) NSNumber *attentcount;
@property (nonatomic, strong) NSNumber *sort;
@property (nonatomic, strong) NSNumber *gid;
@property (nonatomic, strong) NSNumber *readcount;
@property (nonatomic, strong) NSArray *tags;

@property (nonatomic, strong) PushTicpsmodle *model;

@property (nonatomic, assign) CGFloat cellHeight;

@end
