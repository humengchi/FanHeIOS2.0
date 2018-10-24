//
//  NSString+Category.m
//  ChannelPlus
//
//  Created by Peter on 14/12/23.
//  Copyright (c) 2014年 Peter. All rights reserved.
//

#import "NSString+Category.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Category)

+ (NSString *)md5HexDigest:(NSString*)input
{
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];//
    
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%2s",result];
    }
    return ret;
}


+ (id)string2Object:(NSString *)jsonString
{
    if ([CommonMethod isKindOfString:jsonString]) {
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error = nil;
        return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    }
    
    return nil;
}


- (id)string2Object
{
    return [NSString string2Object:self];
}

- (NSString *)decodeBase64:(NSStringEncoding)encoding
{
    NSData *data = [self dataUsingEncoding:encoding];
    return  [data base64decodedString:encoding];
}

- (NSString *)encode2Base64
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return  [data base64EncodedString];
}

- (NSString *)encode2GzipBase64
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSData *dataGZip = [data gzippedData];
    NSString *base64String = [dataGZip base64EncodedStringWithOptions:0];
    return base64String;
}

- (NSString *)gen_uuid
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    
    CFRelease(uuid_string_ref);
    return uuid;
}

+ (NSString*) genUUID
{
    CFUUIDRef    uuidObj = CFUUIDCreate(nil);//create a new UUID
    //get the string representation of the UUID
    NSString    *uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
    CFRelease(uuidObj);
    return [uuidString lowercaseString];
}


+ (NSString *)getLikeStr:(NSString *)str
{
    NSMutableString *likeStr = [[NSMutableString alloc] init];
    [likeStr appendString:@"%"];
    
    if (str.length) {
        [likeStr appendString:str];
    }
    
    [likeStr appendString:@"%"];
    
    return likeStr;
}

+ (NSString *)getNetWorkState{
    UIApplication *app =[UIApplication sharedApplication];
    NSArray *array =[[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    NSString *state = [[NSString alloc] init];
    int netType = 0 ;
    for (id child in array) {
        if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            netType = [[child valueForKeyPath:@"dataNetworkType"] intValue];
            switch (netType) {
                case 0:
                    state = @"无网络";
                    break;
                case 1:
                    state = @"2G" ;
                    break ;
                case 2:
                    state = @"3G" ;
                    break ;
                case 4:
                    state = @"4G" ;
                    break ;
                case 5:
                    state = @"WiFi" ;
                    break ;
                default:
                    break;
            }
            break;
        }
    }
    if ([CommonMethod stringIsNull:state]) {
        state = @"无网络";
    }
    return state ;
}

#define GROUP_MAKRER_STEP 10000
#define DIGIT_MAKRER_STEP 10
/**
 * 阿拉伯数字转汉字
 * http://happle.github.io/blog/2014/05/20/convertArabicNumbersToChinese/
 */
+ (NSString *)convertArabicNumbersToChinese:(NSInteger)arabicNum{
    
    NSArray *groupMarkerLabel  =  @[@"",@"万",@"亿",@"兆"];
    NSArray *digitpMarkerLabel =  @[@"",@"十",@"百",@"千"];
    NSArray *digitsLabel =  @[@"零",@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九"];
    
    NSInteger groupValue;
    NSMutableArray *outpus = [[NSMutableArray alloc] init];
    NSInteger zerosNumber = 0; //用来处理连续的 0
    NSInteger restNumber = arabicNum;
    NSUInteger groupMarkerPos = 0;
    
    do{
        //遍历 `'', '万', '亿', '兆'` 四个组
        groupValue = restNumber % GROUP_MAKRER_STEP;
        if (groupValue) {
            [outpus addObject:[groupMarkerLabel objectAtIndex:groupMarkerPos]];
        }
        NSUInteger digitMarkerPos = 0;
        BOOL ignoreOne = restNumber == 10;// 十位以`一`开头的时候, 可以省略`一`
        NSInteger restGroupValue = groupValue;
        BOOL trailingIsZero = arabicNum > 0; //用来处理全部以 0 来结尾的情况
        NSInteger currentUint ;
        do{
            // 遍历每个组的 `个, 十, 百, 千` 位, 但只从有数字的位数开始，
            // 所以最后需要做一个判断是否补零的处理
            currentUint = restGroupValue % DIGIT_MAKRER_STEP;
            if (trailingIsZero && currentUint) {
                trailingIsZero = NO;
            }
            if (currentUint) {
                [outpus addObject:[digitpMarkerLabel objectAtIndex:digitMarkerPos]];
                zerosNumber = 0;
            }else{
                zerosNumber ++;
            }
            if (!trailingIsZero && !ignoreOne && zerosNumber < 2) {
                [outpus addObject:[digitsLabel objectAtIndex:currentUint]];
            }
            digitMarkerPos ++;
            restGroupValue = floor(restGroupValue / 10);
        }while (restGroupValue > 0);
        groupMarkerPos ++;
        restNumber = floor(restNumber / GROUP_MAKRER_STEP);
        // 判断每个 group 是否需要补零
        // 比如 10,0001 的第一个 group 为 [0001], 但是遍历只从`各`位开始，
        // 所以对于`十`，`百`，`千` 位连续的零需要保留最后一个零，在group前补一个零
        //
        // 并且如果下一组的结尾数字是零的，也需要补一个零
        if (restNumber && groupValue && (groupValue < 1000 || restNumber % 10 == 0)) {
            zerosNumber = 1;
            [outpus addObject:[digitsLabel objectAtIndex:0]];
        }
    }while (restNumber > 0);
    
    NSMutableString *result = [NSMutableString string];
    for(int i = (int)outpus.count - 1; i >= 0; i --){
        NSString *str = (NSString *)[outpus objectAtIndex:i];
        [result appendString:str];
    }
    
    return result;
}

- (NSArray *)componentsSeparated {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i=0; i<self.length; i++) {
        NSString *s = [NSString stringWithFormat:@"%C",[self characterAtIndex:i]];
        [array addObject:s];
    }
    return [array copy];
}

- (NSString *)parseToCamelString {
    if (self==nil || self.length==0) {
        return @"";
    }else if ([self rangeOfString:@"_"].length == 0) {
        return [NSString stringWithFormat:@"%@%@",[self substringWithRange:NSMakeRange(0, 1)].lowercaseString,[self substringFromIndex:1]];
    }
    
    NSArray *strArray = [self componentsSeparatedByString:@"_"];
    NSMutableString *retStr = [[NSMutableString alloc] init];
    for (NSString *s in strArray) {
        if (s.length == 0) {
            continue;
        }
        if (retStr.length == 0) {
            [retStr appendFormat:@"%@",s.lowercaseString];
        }else {
            [retStr appendFormat:@"%@%@",[s substringWithRange:NSMakeRange(0, 1)].uppercaseString,[s substringFromIndex:1].lowercaseString];
        }
    }
    return [retStr copy];
}

+ (NSString *)getUDID{
    
//    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithAccount:KeyChainUDID service:KeyChainUDID accessGroup:KeyChainAccessGroup];
//    NSString *strUUID = [keychainItem objectForKey:(id)CFBridgingRelease(kSecValueData)];
//    
//    //首次执行该方法时，uuid为空
//    if ([strUUID isEqualToString:@""]){
//        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
//        strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
//        [keychainItem setObject:strUUID forKey:(id)CFBridgingRelease(kSecValueData)];
//    }
//    return strUUID;
    return @"";
}

- (NSString *)countNumAndChangeFormat{
    NSInteger count = 0;
    long long int a = self.longLongValue;
    while (a != 0){
        count++;
        a /= 10;
    }
    NSMutableString *string = [NSMutableString stringWithString:self];
    NSMutableString *newstring = [NSMutableString string];
    int first = 1;
    while (count > 3) {
        NSRange rang = NSMakeRange(string.length - 3, 3);
        NSString *str = [string substringWithRange:rang];
        [newstring insertString:str atIndex:0];
        if(!first){
            count -= 3;
            [newstring insertString:@"," atIndex:0];
        }
        first = 0;
        [string deleteCharactersInRange:rang];
    }
    [newstring insertString:string atIndex:0];
    return newstring;
}

+ (NSString*)getNumStr:(NSNumber *)num{
    NSString *str;
    
    if(num.integerValue < 10000){
       return  str = [NSString stringWithFormat:@"%ld", (long)num.integerValue];
//        return num.stringValue;
    }else{
        str = [NSString stringWithFormat:@"%ld万", (long)num.integerValue/10000];
        return str;
    }
}

- (NSString *)filterHTMLNeedBreak{
    NSString *html = [[CommonMethod paramStringIsNull:self] copy];
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO){
        //找到标签的起始位置
        [scanner scanUpToString:@"<" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        if(![text isEqualToString:@"<"]&&![text isEqualToString:@"<br /"]){
            html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
        }
    }
    html = [html stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    return html;
}

- (NSString *)filterHTML{
    NSString *html = [[CommonMethod paramStringIsNull:self] copy];
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO){
        //找到标签的起始位置
        [scanner scanUpToString:@"<" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    html = [html stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    html = [html stringByReplacingOccurrencesOfString:@"    " withString:@""];
    html = [html stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return html;
}


@end
