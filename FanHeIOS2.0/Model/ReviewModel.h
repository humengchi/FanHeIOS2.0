//
//  ReviewModel.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface ReviewModel : BaseModel

@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *realname;
@property (nonatomic, copy) NSString *company;
@property (nonatomic, copy) NSString *position;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *praisecountstr;

@property (nonatomic, strong) NSNumber *userid;
@property (nonatomic, strong) NSNumber *othericon;
@property (nonatomic, strong) NSNumber *usertype;
@property (nonatomic, strong) NSNumber *parent;
@property (nonatomic, strong) NSNumber *praisecount;
@property (nonatomic, strong) NSNumber *parentrevid;
@property (nonatomic, strong) NSNumber *isread;
@property (nonatomic, strong) NSNumber *ishidden;
@property (nonatomic, strong) NSNumber *reviewid;
@property (nonatomic, strong) NSNumber *ispraise;


@property (nonatomic, strong) NSDictionary *replyto;

@property (nonatomic, assign) CGFloat   cellHeight;

@end
