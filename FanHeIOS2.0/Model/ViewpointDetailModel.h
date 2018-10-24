//
//  ViewpointDetailModel.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface ViewpointDetailModel : BaseModel

@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *updated_at;
@property (nonatomic, copy) NSString *praisecountstr;
@property (nonatomic, copy) NSString *subjecttitle;
@property (nonatomic, copy) NSString *mergetitle;
@property (nonatomic, copy) NSString *shareimage;
@property (nonatomic, strong) NSNumber *reviewid;
@property (nonatomic, strong) NSNumber *subject_id;
@property (nonatomic, strong) NSNumber *user_id;
@property (nonatomic, strong) NSNumber *status;
@property (nonatomic, strong) NSNumber *parent;
@property (nonatomic, strong) NSNumber *parentrevid;
@property (nonatomic, strong) NSNumber *praisecount;
@property (nonatomic, strong) NSNumber *admin_user_id;
@property (nonatomic, strong) NSNumber *isread;
@property (nonatomic, strong) NSNumber *ishidden;
@property (nonatomic, strong) NSNumber *mergeto;
@property (nonatomic, strong) NSNumber *ispraise;
@property (nonatomic, strong) NSNumber *isattention;
@property (nonatomic, strong) NSNumber *reviewcount;

@property (nonatomic, strong) UserModel *userModel;

@property (nonatomic, strong) NSArray *praiseusers;

@end
