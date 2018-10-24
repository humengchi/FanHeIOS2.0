//
//  AdminModel.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/9/7.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "AdminModel.h"

@implementation AdminModel

- (void)parseDict:(NSDictionary *)dict{
    [self setValuesForKeysWithDictionary:dict];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.userid = [coder decodeObjectForKey:@"userid"];
        
        self.name = [coder decodeObjectForKey:@"name"];
        self.account = [coder decodeObjectForKey:@"account"];
        self.store = [coder decodeObjectForKey:@"store"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.userid forKey:@"userid"];
    
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.account forKey:@"account"];
    [coder encodeObject:self.store forKey:@"store"];
}

@end
