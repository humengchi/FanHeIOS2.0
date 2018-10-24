//
//  TalkFianaceModel.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "TalkFianaceModel.h"

@implementation TalkFianaceModel

- (void)parseDict:(NSDictionary *)dict{
    self.postid = [CommonMethod paramNumberIsNull:[dict objectForKey:@"postid"]];
    self.readcount = [CommonMethod paramNumberIsNull:[dict objectForKey:@"readcount"]];
    self.usertype = [CommonMethod paramNumberIsNull:[dict objectForKey:@"usertype"]];
    self.hasValidUser = [CommonMethod paramNumberIsNull:[dict objectForKey:@"hasValidUser"]];
    self.reviewcount = [CommonMethod paramNumberIsNull:[dict objectForKey:@"reviewcount"]];
    self.userid = [CommonMethod paramNumberIsNull:[dict objectForKey:@"userid"]];
    
    self.image = [CommonMethod paramStringIsNull:[dict objectForKey:@"image"]];
    
    self.title = [CommonMethod paramStringIsNull:[dict objectForKey:@"title"]];
    self.company = [CommonMethod paramStringIsNull:[dict objectForKey:@"company"]];
    
    self.realname = [CommonMethod paramStringIsNull:[dict objectForKey:@"realname"]];
    self.position = [CommonMethod paramStringIsNull:[dict objectForKey:@"position"]];
}


@end
