//
//  BaseModel.m
//  JinMai
//
//  Created by 胡梦驰 on 16/3/21.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import "BaseModel.h"
#import <objc/runtime.h>

@implementation BaseModel

- (NSDictionary *)properties_aps {
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i<outCount; i++) {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [self valueForKey:(NSString *)propertyName];
        if (propertyValue) [props setObject:propertyValue forKey:propertyName];
    }
    free(properties);
    
    properties = class_copyPropertyList([BaseModel class], &outCount);
    for (i = 0; i<outCount; i++) {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [self valueForKey:(NSString *)propertyName];
        if (propertyValue) [props setObject:propertyValue forKey:propertyName];
    }
    free(properties);
    
    return props;
}

- (NSArray *)properties_virtual_aps {
    return nil;
}

- (NSString *)properties_tableName{
    return nil;
}

- (id)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        [self parseDict:[CommonMethod paramDictIsNull:dict]];
    }
    return self;
}

- (void)parseDict:(NSDictionary *)dict {
    
}

- (id)initWithFMResultSet:(FMResultSet *)set {
    if (self = [super init]) {
        [self parseFMResultSet:set];
    }
    return self;
}

- (void)parseFMResultSet:(FMResultSet *)set {
    
}

@end
