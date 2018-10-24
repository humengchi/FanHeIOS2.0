//
//  CofferModel.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/17.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "CofferModel.h"

@implementation CofferModel
- (void)parseDict:(NSDictionary *)dict{
    self.count = [CommonMethod paramNumberIsNull:[dict objectForKey:@"count"]];
    
    
    self.photo = [CommonMethod paramArrayIsNull:[dict objectForKey:@"photo"]];
    
}
@end
