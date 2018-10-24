//
//  CompanyModel.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/25.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "CompanyModel.h"

@implementation BusinessModel

- (void)parseDict:(NSDictionary *)dict{
    [self setValuesForKeysWithDictionary:dict];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

@end

@implementation CompanyModel

- (void)parseDict:(NSDictionary *)dict{
    [self setValuesForKeysWithDictionary:dict];
    self.businessArray = [NSMutableArray array];
    for(NSDictionary *tmpDict in [CommonMethod paramArrayIsNull:dict[@"business"]]){
        BusinessModel *model = [[BusinessModel alloc] initWithDict:tmpDict];
        [self.businessArray addObject:model];
    }
    
    self.dynamicArray = [NSMutableArray array];
    for(NSDictionary *tmpDict in [CommonMethod paramArrayIsNull:dict[@"dynamic"]]){
        FinanaceDetailModel *model = [[FinanaceDetailModel alloc] initWithDict:tmpDict];
        [self.dynamicArray addObject:model];
    }
    
    self.managerArray = [NSMutableArray array];
    for(NSDictionary *tmpDict in [CommonMethod paramArrayIsNull:dict[@"manager"]]){
        UserModel *model = [[UserModel alloc] initWithDict:tmpDict];
        [self.managerArray addObject:model];
    }
    
    self.employeeArray = [NSMutableArray array];
    for(NSDictionary *tmpDict in [CommonMethod paramArrayIsNull:dict[@"employee"]]){
        UserModel *model = [[UserModel alloc] initWithDict:tmpDict];
        [self.employeeArray addObject:model];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

@end
