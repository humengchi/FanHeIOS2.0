//
//  PraiseActivityModel.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/11/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "PraiseActivityModel.h"

@implementation PraiseActivityModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (void)parseDict:(NSDictionary *)dict{
    if(dict){
        [self setValuesForKeysWithDictionary:dict];
    }
}


@end
