//
//  ReviewModel.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ReviewModel.h"

@implementation ReviewModel

- (void)parseDict:(NSDictionary *)dict{
    [self setValuesForKeysWithDictionary:dict];
    self.cellHeight = [NSHelper heightOfString:self.content font:FONT_SYSTEM_SIZE(14) width:WIDTH-85];
    self.cellHeight += 117+ ((NSInteger)self.cellHeight/17)*6;
    if(self.replyto&&self.replyto.allKeys.count){
        self.cellHeight += 16;
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

@end
