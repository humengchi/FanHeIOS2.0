//
//  NeedModel.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/14.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "NeedModel.h"

@implementation NeedModel

- (void)parseDict:(NSDictionary *)dict{
    [self setValuesForKeysWithDictionary:dict];
    self.intro = [self.intro filterHTMLNeedBreak];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.gxid = [coder decodeObjectForKey:@"gxid"];
        self.dynamic_id = [coder decodeObjectForKey:@"dynamic_id"];
        self.title = [coder decodeObjectForKey:@"title"];
        self.intro = [coder decodeObjectForKey:@"intro"];
        self.created_at = [coder decodeObjectForKey:@"created_at"];
        self.tags = [coder decodeObjectForKey:@"tags"];
        self.count = [coder decodeObjectForKey:@"count"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.gxid forKey:@"gxid"];
    [coder encodeObject:self.dynamic_id forKey:@"dynamic_id"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.intro forKey:@"intro"];
    [coder encodeObject:self.created_at forKey:@"created_at"];
    [coder encodeObject:self.tags forKey:@"tags"];
    [coder encodeObject:self.count forKey:@"count"];
}


@end
