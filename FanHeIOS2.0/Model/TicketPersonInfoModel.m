//
//  TicketPersonInfoModel.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/6/16.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "TicketPersonInfoModel.h"

@implementation TicketPersonInfoModel
- (void)parseDict:(NSDictionary *)dict{
    [self setValuesForKeysWithDictionary:dict];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

@end
