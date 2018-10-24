//
//  LookHistoryModel.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/10/28.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "LookHistoryModel.h"

@implementation LookHistoryModel
- (void)parseDict:(NSDictionary *)dict{
    self.userid = [CommonMethod paramNumberIsNull:[dict objectForKey:@"userid"]];
    self.hasValidUser = [CommonMethod paramNumberIsNull:[dict objectForKey:@"hasValidUser"]];
    self.othericon = [CommonMethod paramNumberIsNull:[dict objectForKey:@"othericon"]];
    self.usertype = [CommonMethod paramNumberIsNull:[dict objectForKey:@"usertype"]];
    self.realname = [CommonMethod paramStringIsNull:[dict objectForKey:@"realname"]];
    self.image = [CommonMethod paramStringIsNull:[dict objectForKey:@"image"]];
    self.company = [CommonMethod paramStringIsNull:[dict objectForKey:@"company"]];
    self.position = [CommonMethod paramStringIsNull:[dict objectForKey:@"position"]];
    self.visitedtime = [CommonMethod paramStringIsNull:[dict objectForKey:@"visitedtime"]];
    
    //活动
    self.applyid = [CommonMethod paramNumberIsNull:[dict objectForKey:@"applyid"]];
    self.price = [CommonMethod paramNumberIsNull:[dict objectForKey:@"price"]];
    self.created_at = [CommonMethod paramStringIsNull:[dict objectForKey:@"created_at"]];
    self.phone = [CommonMethod paramStringIsNull:[dict objectForKey:@"phone"]];
    self.memo = [CommonMethod paramStringIsNull:[dict objectForKey:@"memo"]];
    self.ordernum = [CommonMethod paramStringIsNull:[dict objectForKey:@"ordernum"]];
    
    
    self.status = [CommonMethod paramNumberIsNull:[dict objectForKey:@"status"]];
    self.stat = [CommonMethod paramStringIsNull:[dict objectForKey:@"stat"]];
    self.ticketnum = [CommonMethod paramNumberIsNull:[dict objectForKey:@"ticketnum"]];
    self.remark = [CommonMethod paramStringIsNull:[dict objectForKey:@"remark"]];
    self.ticketid = [CommonMethod paramNumberIsNull:[dict objectForKey:@"ticketid"]];
    self.ticketname = [CommonMethod paramStringIsNull:[dict objectForKey:@"ticketname"]];
    
    NSArray *array = [CommonMethod paramArrayIsNull:dict[@"applyusers"]];
    self.applyusers = [NSMutableArray array];
    for(NSArray *paramArray in array){
        NSMutableArray *valueArray = [NSMutableArray array];
        for(NSDictionary *paramDict in paramArray){
            InfoFieldModel *model = [[InfoFieldModel alloc] initWithDict:paramDict];
            [valueArray addObject:model];
        }
        [self.applyusers addObject:valueArray];
    }
}

@end
