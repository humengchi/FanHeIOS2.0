//
//  SubjectlistModel.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/5/4.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "SubjectlistModel.h"

@implementation SubjectlistModel
- (void)parseDict:(NSDictionary *)dict{
    [self setValuesForKeysWithDictionary:dict];
    self.isAttent = @(0);
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

@end
