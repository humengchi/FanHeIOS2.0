//
//  NSMutableURLRequest+Category.m
//  ChannelPlus
//
//  Created by apple on 15/10/14.
//  Copyright (c) 2015年 Peter. All rights reserved.
//

#import "NSMutableURLRequest+Category.h"

@implementation NSMutableURLRequest (Category)

+(NSString *)boundaryData{
    return @"12436041281943726692693274280";
}

-(void)setFormData:(NSDictionary *)formData{
    
    NSString *boundary = [NSMutableURLRequest boundaryData];
    //设置请求体中内容
    NSMutableString *bodyString = [[NSMutableString alloc]init];
    for (int i=(int)[[formData allKeys] count]-1; i>=0; i--) {
        NSString *key = [formData allKeys][i];
        NSString *value = [formData allValues][i];
        if ([key isEqualToString:@"accessToken"]) {
            value = [value substringToIndex:32];
        }
        [bodyString appendFormat:@"-----------------------------%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n",boundary,key,value];
    }
    [bodyString appendFormat:@"-----------------------------%@--\r\n", boundary];
    NSMutableData *bodyData = [[NSMutableData alloc]initWithLength:0];
    NSData *bodyStringData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [bodyData appendData:bodyStringData];
    NSString *contentLength = [NSString stringWithFormat:@"%d",(int)[bodyData length]];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=---------------------------%@", boundary];
    [self setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [self setValue:contentLength forHTTPHeaderField:@"Content-Length"];
    [self setHTTPBody:bodyData];
    [self setHTTPMethod:@"POST"];
}

@end
