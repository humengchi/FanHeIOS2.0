//
//  DataModelInstance.h
//  JinMai
//
//  Created by 胡梦驰 on 16/3/22.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataModelInstance : NSData

@property (nonatomic, copy) NSString *tokenStr;

@property (nonatomic, strong) NSString *qiNiuTokenStr;

@property (nonatomic, strong) NSString *qiNiuUrl;

@property (nonatomic, strong) UserModel *userModel;

@property (nonatomic, strong) NSNumber *coffeeBeans;


@property (nonatomic, strong) AdminModel *adminUserModel;

+ (DataModelInstance *)shareInstance;

@end
