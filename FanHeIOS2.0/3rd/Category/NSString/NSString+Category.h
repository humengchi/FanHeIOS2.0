//
//  NSString+Category.h
//  ChannelPlus
//
//  Created by Peter on 14/12/23.
//  Copyright (c) 2014年 Peter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Category)
+ (NSString *)md5HexDigest:(NSString*)input;

+ (id)string2Object:(NSString *)jsonString;

- (id)string2Object;

- (NSString *)decodeBase64:(NSStringEncoding)encoding;
- (NSString *)encode2Base64;

- (NSString *)encode2GzipBase64;

- (NSArray *)componentsSeparated;

- (NSString *)parseToCamelString;

+ (NSString *)genUUID;
+ (NSString *)getLikeStr:(NSString *)str;

+ (NSString *)getNetWorkState;

+ (NSString *)convertArabicNumbersToChinese:(NSInteger)arabicNum;

+ (NSString *)getUDID;

- (NSString *)countNumAndChangeFormat;

//根据传入的点赞/阅读数，超过四位数变成1W
+ (NSString*)getNumStr:(NSNumber*)num;

- (NSString *)filterHTML;

- (NSString *)filterHTMLNeedBreak;

@end
