//
//  SubjectModel.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/10/28.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "SubjectModel.h"

@implementation SubjectModel
- (void)parseDict:(NSDictionary *)dict{
    self.business = [CommonMethod paramStringIsNull:[dict objectForKey:@"business"]];
    self.businessID = [CommonMethod paramNumberIsNull:[dict objectForKey:@"businessID"]];
    self.title = [CommonMethod paramStringIsNull:[dict objectForKey:@"title"]];
    self.image = [CommonMethod paramStringIsNull:[dict objectForKey:@"image"]];
    self.url = [CommonMethod paramStringIsNull:[dict objectForKey:@"url"]];
    self.subjectId = [CommonMethod paramNumberIsNull:[dict objectForKey:@"id"]];
}


@end
