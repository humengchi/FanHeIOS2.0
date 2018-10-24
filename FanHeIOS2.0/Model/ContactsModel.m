//
//  ContactsModel.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/9.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ContactsModel.h"

@implementation ContactsModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{

}

- (void)parseDict:(NSDictionary *)dict{
    [self setValuesForKeysWithDictionary:dict];
    self.workyearstr = [CommonMethod paramStringIsNull:[dict objectForKey:@"workyearstr"]];
    
    self.type = [CommonMethod paramNumberIsNull:dict[@"show"][@"type"]];
    self.count = [CommonMethod paramNumberIsNull:dict[@"show"][@"val"][@"count"]];
    self.userArray = [NSMutableArray array];
    for(NSDictionary *userDict in [CommonMethod paramArrayIsNull:dict[@"show"][@"val"][@"list"]]){
        UserModel *model = [[UserModel alloc] initWithDict:userDict];
        [self.userArray addObject:model];
    }
    
    self.cellHeight = 110;
    NSString *needStr = [CommonMethod paramStringIsNull:self.need];
    NSString *supplyStr = [CommonMethod paramStringIsNull:self.supply];
    if(needStr.length && supplyStr.length){
        self.cellHeight = 193;
    }else if(needStr.length || supplyStr.length){
        self.cellHeight = 147;
    }
    
    //好友申请详情
    if([[[CommonMethod paramDictIsNull:dict[@"comfriend"]] allKeys] count]){
        self.count = [CommonMethod paramNumberIsNull:dict[@"comfriend"][@"count"]];
        self.userArray = [NSMutableArray array];
        for(NSString *imageStr in [CommonMethod paramArrayIsNull:dict[@"comfriend"][@"list"]]){
            if([[CommonMethod paramStringIsNull:imageStr] length]){
                [self.userArray addObject:imageStr];
            }
        }
    }
}

@end
