//
//  RKUserDefaults.h
//  ChannelPlus
//
//  Created by Rookie Wang on 15/8/3.
//  Copyright (c) 2015年 Peter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RKUserDefaults : NSObject

+ (RKUserDefaults *)standardUserDefaults;

- (NSMutableDictionary *)loadUserDefaultsDictionary;

- (NSArray *)allKeys;

- (void)removeObjectForKey:(NSString *)defaultName;
- (void)setObject:(id)value forKey:(NSString *)defaultName;

- (void)setString:(NSString *)value forKey:(NSString *)defaultName;
- (void)setArray:(NSArray *)value forKey:(NSString *)defaultName;
- (void)setDictionary:(NSDictionary *)value forKey:(NSString *)defaultName;
- (void)setData:(NSData *)value forKey:(NSString *)defaultName;
- (void)setStringArray:(NSArray *)value forKey:(NSString *)defaultName;

- (void)setNumber:(NSNumber *)value forKey:(NSString *)defaultName;
- (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName;
- (void)setFloat:(float)value forKey:(NSString *)defaultName;
- (void)setDouble:(double)value forKey:(NSString *)defaultName;
- (void)setBool:(BOOL)value forKey:(NSString *)defaultName;


- (id)objectForKey:(NSString *)defaultName;

- (NSString *)stringForKey:(NSString *)defaultName;
- (NSArray *)arrayForKey:(NSString *)defaultName;
- (NSDictionary *)dictionaryForKey:(NSString *)defaultName;
- (NSData *)dataForKey:(NSString *)defaultName;
- (NSArray *)stringArrayForKey:(NSString *)defaultName;

- (NSNumber *)numberForKey:(NSString *)defaultName;
- (NSInteger)integerForKey:(NSString *)defaultName;
- (float)floatForKey:(NSString *)defaultName;
- (double)doubleForKey:(NSString *)defaultName;
- (BOOL)boolForKey:(NSString *)defaultName;

@end
