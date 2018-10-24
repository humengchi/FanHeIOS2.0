//
//  TaMessageModel.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "TaMessageModel.h"

@implementation TaMessageModel

- (void)parseDict:(NSDictionary *)dict{
    self.hasValidUser = [CommonMethod paramNumberIsNull:[dict objectForKey:@"hasValidUser"]];
     self.usertype = [CommonMethod paramNumberIsNull:[dict objectForKey:@"usertype"]];
     self.canviewphone = [CommonMethod paramNumberIsNull:[dict objectForKey:@"canviewphone"]];

    self.isattention = [CommonMethod paramNumberIsNull:[dict objectForKey:@"isattention"]];
    self.iscoffee = [CommonMethod paramNumberIsNull:[dict objectForKey:@"iscoffee"]];
    self.isfriend = [CommonMethod paramNumberIsNull:[dict objectForKey:@"isfriend"]];
    
    self.attentionhenum = [CommonMethod paramNumberIsNull:[dict objectForKey:@"attentionhenum"]];
    self.hisattentionnum = [CommonMethod paramNumberIsNull:[dict objectForKey:@"hisattentionnum"]];
    self.workyear = [CommonMethod paramNumberIsNull:[dict objectForKey:@"workyear"]];
    self.friendnum = [CommonMethod paramNumberIsNull:[dict objectForKey:@"friendnum"]];
    self.comfriendnum = [CommonMethod paramNumberIsNull:[dict objectForKey:@"comfriendnum"]];
   
    
    self.workyearstr = [CommonMethod paramStringIsNull:[dict objectForKey:@"workyearstr"]];
    self.mystate = [CommonMethod paramStringIsNull:[dict objectForKey:@"mystate"]];

    self.image = [CommonMethod paramStringIsNull:[dict objectForKey:@"image"]];
    self.email = [CommonMethod paramStringIsNull:[dict objectForKey:@"email"]];
    self.phone = [CommonMethod paramStringIsNull:[dict objectForKey:@"phone"]];
    self.position = [CommonMethod paramStringIsNull:[dict objectForKey:@"position"]];
    self.realname = [CommonMethod paramStringIsNull:[dict objectForKey:@"realname"]];
    self.video = [CommonMethod paramStringIsNull:[dict objectForKey:@"video"]];
    self.remark = [CommonMethod paramStringIsNull:[dict objectForKey:@"remark"]];
    self.city = [CommonMethod paramStringIsNull:[dict objectForKey:@"city"]];
    self.business = [CommonMethod paramArrayIsNull:[dict objectForKey:@"business"]];
    self.company = [CommonMethod paramStringIsNull:[dict objectForKey:@"company"]];
    self.weixin = [CommonMethod paramStringIsNull:[dict objectForKey:@"weixin"]];
     self.industry = [CommonMethod paramStringIsNull:[dict objectForKey:@"industry"]];
}


@end
