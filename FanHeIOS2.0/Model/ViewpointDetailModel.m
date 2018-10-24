//
//  ViewpointDetailModel.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ViewpointDetailModel.h"

@implementation ViewpointDetailModel

- (void)parseDict:(NSDictionary *)dict{
    [self setValuesForKeysWithDictionary:dict];
    
    self.userModel = [[UserModel alloc] initWithDict:[CommonMethod paramDictIsNull:dict[@"user"]]];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

@end
