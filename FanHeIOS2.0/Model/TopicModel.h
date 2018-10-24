//
//  TopicModel.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/20.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface TopicModel : BaseModel

@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) NSNumber *sid;
@property (nonatomic, strong) NSNumber *replycount;
@property (nonatomic, strong) NSNumber *attentcount;
@property (nonatomic, strong) NSNumber *reviewcount;
@property (nonatomic, strong) NSArray *tagname;


@property (nonatomic, strong) NSNumber *pid;
@property (nonatomic, strong) NSNumber *readcount;

@property (nonatomic, assign) CGFloat cellHeight;

@end
