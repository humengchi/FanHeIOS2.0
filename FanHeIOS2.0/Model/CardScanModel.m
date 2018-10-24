//
//  CardScanModel.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/14.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "CardScanModel.h"

@implementation CardGroupModel

- (void)parseDict:(NSDictionary *)dict{
    self.groupname = [CommonMethod paramStringIsNull:dict[@"groupname"]];
    
    self.groupid = [CommonMethod paramNumberIsNull:dict[@"groupid"]];
    self.cnt = [CommonMethod paramNumberIsNull:dict[@"cnt"]];
    self.isSelected = @(0);
}


@end

@implementation CardScanModel

- (void)parseDict:(NSDictionary *)dict{
    self.position = [NSMutableArray arrayWithArray:[CommonMethod paramArrayIsNull:dict[@"position"]]];
    self.company = [NSMutableArray arrayWithArray:[CommonMethod paramArrayIsNull:dict[@"company"]]];
    self.address = [NSMutableArray arrayWithArray:[CommonMethod paramArrayIsNull:dict[@"address"]]];
    self.jobphone = [NSMutableArray arrayWithArray:[CommonMethod paramArrayIsNull:dict[@"jobphone"]]];
    self.fax = [NSMutableArray arrayWithArray:[CommonMethod paramArrayIsNull:dict[@"fax"]]];
    self.email = [NSMutableArray arrayWithArray:[CommonMethod paramArrayIsNull:dict[@"email"]]];
    self.website = [NSMutableArray arrayWithArray:[CommonMethod paramArrayIsNull:dict[@"website"]]];
    self.qq = [NSMutableArray arrayWithArray:[CommonMethod paramArrayIsNull:dict[@"qq"]]];
    self.wx = [NSMutableArray arrayWithArray:[CommonMethod paramArrayIsNull:dict[@"wx"]]];
    self.groups = [NSMutableArray arrayWithArray:[CommonMethod paramArrayIsNull:dict[@"groups"]]];
    
    self.name = [CommonMethod paramStringIsNull:dict[@"name"]];
    self.letter = [CommonMethod paramStringIsNull:dict[@"letter"]];
    self.zipcode = [CommonMethod paramStringIsNull:dict[@"zipcode"]];
    self.imgurl = [CommonMethod paramStringIsNull:dict[@"imgurl"]];
    self.birthday = [CommonMethod paramStringIsNull:dict[@"birthday"]];
    self.updated_at = [CommonMethod paramStringIsNull:dict[@"updated_at"]];
    self.created_at = [CommonMethod paramStringIsNull:dict[@"created_at"]];
    self.phone = [CommonMethod paramStringIsNull:dict[@"phone"]];
    self.remark = [CommonMethod paramStringIsNull:dict[@"remark"]];
    
    self.btn = [CommonMethod paramNumberIsNull:dict[@"btn"]];
    self.source = [CommonMethod paramNumberIsNull:dict[@"source"]];
    self.cardId = [CommonMethod paramNumberIsNull:dict[@"id"]];
    self.user_id = [CommonMethod paramNumberIsNull:dict[@"user_id"]];
    self.ismycard = [CommonMethod paramNumberIsNull:dict[@"ismycard"]];
    self.otherid = [CommonMethod paramNumberIsNull:dict[@"otherid"]];
}

@end
