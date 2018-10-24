//
//  NotSecoundModel.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/21.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "NotSecoundModel.h"

@implementation NotSecoundModel
- (void)parseDict:(NSDictionary *)dict{
    self.subjectid = [CommonMethod paramNumberIsNull:[dict objectForKey:@"subjectid"]];
    self.replycount = [CommonMethod paramNumberIsNull:[dict objectForKey:@"replycount"]];
    self.reviewcount = [CommonMethod paramNumberIsNull:[dict objectForKey:@"reviewcount"]];
    self.attentcount = [CommonMethod paramNumberIsNull:[dict objectForKey:@"attentcount"]];
    self.srcnt = [CommonMethod paramNumberIsNull:[dict objectForKey:@"srcnt"]];
    
    
    self.title = [CommonMethod paramStringIsNull:[dict objectForKey:@"title"]];
    self.realname = [CommonMethod paramStringIsNull:[dict objectForKey:@"realname"]];
    self.createtime = [CommonMethod paramStringIsNull:[dict objectForKey:@"createtime"]];
    self.content = [CommonMethod paramStringIsNull:[dict objectForKey:@"content"]];
    
    
    self.readcount = [CommonMethod paramNumberIsNull:[dict objectForKey:@"readcount"]];
    self.gid = [CommonMethod paramNumberIsNull:[dict objectForKey:@"gid"]];
    self.type = [CommonMethod paramNumberIsNull:[dict objectForKey:@"type"]];
    self.reviewid = [CommonMethod paramNumberIsNull:[dict objectForKey:@"reviewid"]];
    self.parent = [CommonMethod paramNumberIsNull:[dict objectForKey:@"parent"]];
    self.parentrevid = [CommonMethod paramNumberIsNull:[dict objectForKey:@"parentrevid"]];
    
    self.mypraisecount = [CommonMethod paramNumberIsNull:[dict objectForKey:@"mypraisecount"]];
    self.myreviewcount = [CommonMethod paramNumberIsNull:[dict objectForKey:@"myreviewcount"]];
    
}

@end
