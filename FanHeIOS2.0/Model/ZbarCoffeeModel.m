//
//  ZbarCoffeeModel.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/18.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ZbarCoffeeModel.h"


@implementation ZbarUserModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (void)parseDict:(NSDictionary *)dict{
    if(dict){
        [self setValuesForKeysWithDictionary:dict];
    }
}

@end

@implementation ZbarCoffeeModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{

}

- (void)parseDict:(NSDictionary *)dict{
    if(dict){
        [self setValuesForKeysWithDictionary:dict];
        self.user = [[ZbarUserModel alloc] initWithDict:dict[@"user"]];
    }
}

@end


