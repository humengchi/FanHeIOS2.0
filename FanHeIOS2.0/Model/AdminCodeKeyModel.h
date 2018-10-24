//
//  AdminCodeKeyModel.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/9/18.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface AdminCodeKeyModel : BaseModel

@property (nonatomic, copy) NSString    *cdkey;
@property (nonatomic, copy) NSString    *sendtime;
@property (nonatomic, copy) NSString    *remark;
@property (nonatomic, copy) NSString    *username;

@property (nonatomic, strong) NSNumber  *status;
@property (nonatomic, strong) NSNumber  *userid;

@end
