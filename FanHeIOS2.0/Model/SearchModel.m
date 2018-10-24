//
//  SearchModel.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/1/20.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "SearchModel.h"

@implementation SearchModel

- (void)parseDict:(NSDictionary *)dict{
    self.rid = [CommonMethod paramNumberIsNull:dict[@"rid"]];
    self.othericon = [CommonMethod paramNumberIsNull:dict[@"othericon"]];
    self.hasValidUser = [CommonMethod paramNumberIsNull:dict[@"hasValidUser"]];
    self.usertype = [CommonMethod paramNumberIsNull:dict[@"usertype"]];
    self.status = [CommonMethod paramNumberIsNull:dict[@"status"]];
    self.attentcount = [CommonMethod paramNumberIsNull:dict[@"attentcount"]];
    self.replycount = [CommonMethod paramNumberIsNull:dict[@"replycount"]];
    self.reviewcount = [CommonMethod paramNumberIsNull:dict[@"reviewcount"]];
    self.addresstype = [CommonMethod paramNumberIsNull:dict[@"addresstype"]];
    self.readcount = [CommonMethod paramNumberIsNull:dict[@"readcount"]];
    
    self.friends = [CommonMethod paramArrayIsNull:dict[@"friend"]];
    self.tags = [CommonMethod paramArrayIsNull:dict[@"tags"]];
    
    self.name = [CommonMethod paramStringIsNull:dict[@"name"]];
    self.company = [CommonMethod paramStringIsNull:dict[@"company"]];
    self.position = [CommonMethod paramStringIsNull:dict[@"position"]];
    self.image = [CommonMethod paramStringIsNull:dict[@"image"]];
    self.starttime = [CommonMethod paramStringIsNull:dict[@"starttime"]];
    self.endtime = [CommonMethod paramStringIsNull:dict[@"endtime"]];
    self.provincename = [CommonMethod paramStringIsNull:dict[@"provincename"]];
    self.cityname = [CommonMethod paramStringIsNull:dict[@"cityname"]];
    self.districtname = [CommonMethod paramStringIsNull:dict[@"districtname"]];
    self.timestr = [CommonMethod paramStringIsNull:dict[@"timestr"]];
    self.guestname = [CommonMethod paramStringIsNull:dict[@"guestname"]];
    self.price = [CommonMethod paramStringIsNull:dict[@"price"]];
    
    self.relation = [CommonMethod paramStringIsNull:dict[@"relation"]];
    self.samefriend = [CommonMethod paramNumberIsNull:dict[@"samefriend"]];
}

@end
