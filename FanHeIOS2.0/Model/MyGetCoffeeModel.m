//
//  MyGetCoffeeModel.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/26.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "MyGetCoffeeModel.h"

@implementation MyGetCoffeeModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{

}

- (void)parseDict:(NSDictionary *)dict{
    [self setValuesForKeysWithDictionary:dict];
    
    self.cellHeight = 101;
}

@end
