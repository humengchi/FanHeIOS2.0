//
//  ActivityNoteModel.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/1/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ActivityNoteModel.h"

@implementation ActivityNoteModel

- (void)parseDict:(NSDictionary *)dict{
    [self setValuesForKeysWithDictionary:dict];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

@end
