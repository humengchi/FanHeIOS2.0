
//
//  workHistryModel.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/10/28.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "workHistryModel.h"

@implementation workHistryModel
- (void)parseDict:(NSDictionary *)dict{
    self.careerid = [CommonMethod paramNumberIsNull:dict[@"careerid"]];
    self.companyid = [CommonMethod paramNumberIsNull:dict[@"companyid"]];
    self.company = [CommonMethod paramStringIsNull:[dict objectForKey:@"company"]];
    self.position = [CommonMethod paramStringIsNull:[dict objectForKey:@"position"]];
    self.begintime = [CommonMethod paramStringIsNull:[dict objectForKey:@"begintime"]];
    self.endtime = [CommonMethod paramStringIsNull:[dict objectForKey:@"endtime"]];
    self.jobintro = [CommonMethod paramStringIsNull:[dict objectForKey:@"jobintro"]];
    self.logo = [CommonMethod paramStringIsNull:[dict objectForKey:@"logo"]];
    self.attestationtotal = [CommonMethod paramNumberIsNull:[dict objectForKey:@"attestationtotal"]];
    self.attestationlist = [CommonMethod paramArrayIsNull:[dict objectForKey:@"attestationlist"]];
    self.isattestation = [CommonMethod paramNumberIsNull:[dict objectForKey:@"isattestation"]];
    self.image = [CommonMethod paramArrayIsNull:[dict objectForKey:@"image"]];
    self.url = [CommonMethod paramArrayIsNull:[dict objectForKey:@"url"]];
    self.isfriend = [CommonMethod paramNumberIsNull:[dict objectForKey:@"isfriend"]];
}

@end
