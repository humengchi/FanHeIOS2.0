
//
//  MyHomeTopicModel.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/22.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "MyHomeTopicModel.h"

@implementation MyHomeTopicModel
- (void)parseDict:(NSDictionary *)dict{
    self.sreplycount = [CommonMethod paramNumberIsNull:[dict objectForKey:@"sreplycount"]];
    self.sattentcount = [CommonMethod paramNumberIsNull:[dict objectForKey:@"sattentcount"]];
    self.sreviewcount = [CommonMethod paramNumberIsNull:[dict objectForKey:@"sreviewcount"]];
    self.sid = [CommonMethod paramNumberIsNull:[dict objectForKey:@"sid"]];
    self.srid = [CommonMethod paramNumberIsNull:[dict objectForKey:@"srid"]];
    self.srpraisecount = [CommonMethod paramNumberIsNull:[dict objectForKey:@"srpraisecount"]];
    self.srreviewcount = [CommonMethod paramNumberIsNull:[dict objectForKey:@"srreviewcount"]];
    
    
    self.title = [CommonMethod paramStringIsNull:[dict objectForKey:@"title"]];
    self.content = [CommonMethod paramStringIsNull:[dict objectForKey:@"content"]];
    self.created_at = [CommonMethod paramStringIsNull:[dict objectForKey:@"created_at"]];
    
    
       
}


@end
