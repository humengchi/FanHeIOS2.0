//
//  RKUserDefaults.m
//  ChannelPlus
//
//  Created by Rookie Wang on 15/8/3.
//  Copyright (c) 2015年 Peter. All rights reserved.
//

#import "RKUserDefaults.h"

#define userDefaultsPlistPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/User/ConfigSetting.plist"]

@interface RKUserDefaults()

@end

@implementation RKUserDefaults

+ (RKUserDefaults *)standardUserDefaults {
    static RKUserDefaults *userDefaults = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userDefaults = [[RKUserDefaults alloc] init];
    });
    return userDefaults;
}

- (NSMutableDictionary *)loadUserDefaultsDictionary {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:userDefaultsPlistPath];
    if (dic == nil) {
        dic = [[NSMutableDictionary alloc] init];
    }
    return dic;
}

- (NSArray *)allKeys {
    NSMutableDictionary *dic = [self loadUserDefaultsDictionary];
    return [dic allKeys];
}

//write
- (BOOL)synchronize:(NSDictionary *)dic {
    return [dic writeToFile:userDefaultsPlistPath atomically:YES];
}

- (void)removeObjectForKey:(NSString *)defaultName {
    NSMutableDictionary *dic = [self loadUserDefaultsDictionary];
    [dic removeObjectForKey:defaultName];
    [self synchronize:dic];
}

- (void)setObject:(id)value forKey:(NSString *)defaultName {
    NSMutableDictionary *dic = [self loadUserDefaultsDictionary];
    [dic setObject:value forKey:defaultName];
    [self synchronize:dic];
}

- (void)setString:(NSString *)value forKey:(NSString *)defaultName {
    [self setObject:value forKey:defaultName];
}

- (void)setArray:(NSArray *)value forKey:(NSString *)defaultName {
    [self setObject:value forKey:defaultName];
}

- (void)setDictionary:(NSDictionary *)value forKey:(NSString *)defaultName {
    [self setObject:value forKey:defaultName];
}

- (void)setData:(NSData *)value forKey:(NSString *)defaultName {
    [self setObject:value forKey:defaultName];
}

- (void)setStringArray:(NSArray *)value forKey:(NSString *)defaultName {
    [self setObject:value forKey:defaultName];
}

- (void)setNumber:(NSNumber *)value forKey:(NSString *)defaultName {
    [self setObject:value forKey:defaultName];
}

- (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName {
    [self setNumber:[NSNumber numberWithInteger:value] forKey:defaultName];
}

- (void)setFloat:(float)value forKey:(NSString *)defaultName {
    [self setNumber:[NSNumber numberWithFloat:value] forKey:defaultName];
}

- (void)setDouble:(double)value forKey:(NSString *)defaultName {
    [self setNumber:[NSNumber numberWithDouble:value] forKey:defaultName];
}

- (void)setBool:(BOOL)value forKey:(NSString *)defaultName {
    [self setNumber:[NSNumber numberWithBool:value] forKey:defaultName];
}

//read
- (id)objectForKey:(NSString *)defaultName {
    return [[self loadUserDefaultsDictionary] objectForKey:defaultName];
}

- (NSString *)stringForKey:(NSString *)defaultName {
    return (NSString *)[self objectForKey:defaultName];
}

- (NSArray *)arrayForKey:(NSString *)defaultName {
    return (NSArray *)[self objectForKey:defaultName];
}

- (NSDictionary *)dictionaryForKey:(NSString *)defaultName {
    return (NSDictionary *)[self objectForKey:defaultName];
}

- (NSData *)dataForKey:(NSString *)defaultName {
    return (NSData *)[self objectForKey:defaultName];
}

- (NSArray *)stringArrayForKey:(NSString *)defaultName {
    return (NSArray *)[self objectForKey:defaultName];
}

- (NSNumber *)numberForKey:(NSString *)defaultName {
    return (NSNumber *)[self objectForKey:defaultName];
}

- (NSInteger)integerForKey:(NSString *)defaultName {
    return [self numberForKey:defaultName].integerValue;
}

- (float)floatForKey:(NSString *)defaultName {
    return [self numberForKey:defaultName].floatValue;
}

- (double)doubleForKey:(NSString *)defaultName {
    return [self numberForKey:defaultName].doubleValue;
}

- (BOOL)boolForKey:(NSString *)defaultName {
    return [self numberForKey:defaultName].boolValue;
}

@end
