//
//  DynamicDetailModel.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/3/1.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface DynamicDetailModel : BaseModel

@property (nonatomic, copy) NSString   *rightimage;
@property (nonatomic, copy) NSString    *rightcontent;
@property (nonatomic, copy) NSString    *content;
@property (nonatomic, copy) NSString    *created_at;
@property (nonatomic, copy) NSString   *realname;
@property (nonatomic, copy) NSString   *image;

@property (nonatomic, copy)NSString   *msg;

@property (nonatomic, strong) NSNumber *lasttime;
@property (nonatomic, strong) NSNumber *usertype;
@property (nonatomic, strong) NSNumber *userid;
@property (nonatomic, strong) NSNumber *dynamic_review_id;
@property (nonatomic, strong) NSNumber *dynamic_id;


@end
