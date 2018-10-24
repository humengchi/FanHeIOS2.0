//
//  PushTicpsmodle.h
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface PushTicpsmodle : BaseModel
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *realname;
@property (nonatomic, strong) NSNumber *userid;
@property (nonatomic, strong) NSNumber *usertype;
@property (nonatomic, strong) NSNumber *ishidden;
@end
