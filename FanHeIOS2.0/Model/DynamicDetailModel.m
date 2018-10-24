//
//  DynamicDetailModel.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/3/1.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "DynamicDetailModel.h"

@implementation DynamicDetailModel
- (void)parseDict:(NSDictionary *)dict{
    [self setValuesForKeysWithDictionary:dict];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

//- (void)parseDict:(NSDictionary *)dict{
//    self.usertype = [CommonMethod paramNumberIsNull:dict[@"usertype"]];
//    self.userid = [CommonMethod paramNumberIsNull:dict[@"userid"]];
//    self.dynamic_review_id = [CommonMethod paramNumberIsNull:dict[@"dynamic_review_id"]];
//    self.dynamic_id = [CommonMethod paramNumberIsNull:dict[@"dynamic_id"]];
//       
//    self.rightimage = [CommonMethod paramStringIsNull:dict[@"rightimage"]];
//    self.rightcontent = [CommonMethod paramStringIsNull:dict[@"rightcontent"]];
//    self.content = [CommonMethod paramStringIsNull:dict[@"content"]];
//    self.lasttime = [CommonMethod paramStringIsNull:dict[@"lasttime"]];
//    self.realname = [CommonMethod paramStringIsNull:dict[@"realname"]];
//    self.image = [CommonMethod paramStringIsNull:dict[@"image"]];
//}
//
@end
