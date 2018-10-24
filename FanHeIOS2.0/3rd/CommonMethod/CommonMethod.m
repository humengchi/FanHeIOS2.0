//
//  CommonMethod.m
//  ChannelPlus
//
//  Created by Peter on 14/12/15.
//  Copyright (c) 2014年 Peter. All rights reserved.
//

#import "CommonMethod.h"
//#import "OpenUDID.h"

#define kSquareColor [UIColor colorWithRed:0.004 green:0.349 blue:0.616 alpha:1]
#define kSquareSideLength 64.0f
#define kSquareCornerRadius 10.0f
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation CommonMethod


+ (BOOL)isKindOfClass:(id)value class:(Class)class
{
    if (value && ![value isEqual:[NSNull null]] && [value isKindOfClass:class]) {
        return  TRUE;
    }
    
    return FALSE;
}

+ (BOOL)isKindOfDictionary:(id)value
{
    
    return [self isKindOfClass:value class:[NSDictionary class]];
}

+ (BOOL)isKindOfNSNumber:(id)value
{
    
    return [self isKindOfClass:value class:[NSNumber class]];
}

+ (BOOL)isKindOfArray:(id)value
{
    
    return [self isKindOfClass:value class:[NSArray class]];
}

+ (BOOL)isKindOfString:(id)value
{
    return [self isKindOfClass:value class:[NSString class]];
}

+ (NSString *)paramStringIsNull:(NSString *)param
{
    return ([param isEqual:[NSNull null]] || param == nil ) ? @"" : param;
}

+ (BOOL)stringIsNull:(NSString *)value
{
    return ([value isEqual:[NSNull null]] || value == nil || [value isEqualToString:@""]) ? YES : NO;
}

+ (BOOL)webIsLink{
    // 使用
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    if (reach.isReachable) {// 本地有网
        return YES;
    }else{
        return NO;
    }
}

+ (BOOL)urlIsValid:(NSURL*)httpUrl{
    // 使用
    Reachability *reach = [Reachability reachabilityWithHostName:@"api.map.baidu.com"];
    if (reach.isReachable) {// 本地有网
        NSURLRequest *request = [NSURLRequest requestWithURL:httpUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:0.5];
        NSHTTPURLResponse *response;
        [NSURLConnection sendSynchronousRequest:request returningResponse: &response error: nil];
        if (!response){// 访问地址不通
            return NO;
        }else{
            return YES;
        }
    }else{
        return NO;
    }
}

+ (NSString *)paramStringIsNull:(NSString *)param format:(NSString *)format {
    return ([param isEqual:[NSNull null]] || param == nil || [param isEqualToString:@""]) ? format : param;
}

+ (NSArray *)paramArrayIsNull:(NSArray *)param
{
    return ([param isEqual:[NSNull null]] || param == nil ) ? @[] : param;
}

+ (NSDictionary *)paramDictIsNull:(NSDictionary *)param
{
    return ([param isEqual:[NSNull null]] || param == nil ) ? @{} : param;
}

+ (NSNumber *)paramNumberIsNull:(NSNumber *)param
{
    if ([param isKindOfClass:[NSNumber class]]) {
        
        return ([param isEqual:[NSNull null]] || param == nil || [param isEqual: @""]) ? NUMBER(0) : param;
    }else if ([param isKindOfClass:[NSString class]]) {
        NSString *num = (NSString *)param;
        return [[CommonMethod paramStringIsNull:num] isEqualToString:@""] ? NUMBER(0) : [NSNumber numberWithDouble:[num doubleValue]];
    }
    
    return NUMBER(0);
}

+ (NSNumber *)paramNumberDoubleIsNull:(NSNumber *)param
{
    if ([param isKindOfClass:[NSNumber class]]) {
        
        return ([param isEqual:[NSNull null]] || param == nil || [param isEqual: @""]) ? NUMBER(0) : param;
    }else if ([param isKindOfClass:[NSString class]]) {
        NSString *num = (NSString *)param;
        return [[CommonMethod paramStringIsNull:num] isEqualToString:@""] ? NUMBER(0) : [NSNumber numberWithDouble:[num doubleValue]];
    }
    return NUMBER(0);
    return ([param isEqual:[NSNull null]] || param == nil || [param isEqual: @""]) ? NUMBER_DOUBLE(0) : param;
}


+ (void)updateTime:(dispatch_source_t )timer delaySecond:(double)delaySecond completion:(void(^)())completion
{
    dispatch_source_set_timer(timer, dispatch_walltime(DISPATCH_TIME_NOW, 0), delaySecond*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            if (completion) {
                completion();
            }
        });
    });
    
    dispatch_resume(timer);
}

+(id)getViewFromNib:(NSString *)nibName
{
    NSArray* nibView =  [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    return [nibView objectAtIndex:0];
}

+ (id)getVCFromNib:(Class)cls
{
    return [[cls alloc] initWithNibName:NSStringFromClass(cls) bundle:nil];
}

+ (id)getVCFromNib:(Class)cls nibName:(NSString *)nibName {
    return [[cls alloc] initWithNibName:nibName bundle:nil];
}

+ (UITapGestureRecognizer*)viewAddGuestureRecognizer:(UIView *)view tapsNumber:(int)tapsNumber withTarget:(id)target withSEL:(SEL)sel
{
    view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:target action:sel];
    singleTap.numberOfTapsRequired = tapsNumber;
    [view addGestureRecognizer:singleTap];
    return singleTap;
}



+ (void)changeViewSize:(UIView *)view endFrame:(CGRect)endFrame completion:(void(^)(BOOL finished))completion
{
    [UIView animateWithDuration:.3f animations:^{
        view.frame = endFrame;
    } completion:completion];
}

+ (void)changeViewSize:(UIView *)view startFrame:(CGRect)startFrame endFrame:(CGRect)endFrame completion:(void(^)(BOOL finished))completion
{
    view.frame = startFrame;
    [UIView animateWithDuration:.3f animations:^{
        view.frame = endFrame;
    } completion:completion];
}

+ (NSString *)getAppInfo
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    //NSString *appVersion = [NSString stringWithFormat:@"V%@", [infoDictionary objectForKey:@"CFBundleShortVersionString"]];
    NSString *appVersion = [NSString stringWithFormat:@"%@", [infoDictionary objectForKey:@"CFBundleShortVersionString"]];
    
    NSString *platform = @"ios";
    
    NSString *deviceVersion = [[UIDevice currentDevice] systemVersion];
    
    
//    NSString *info = [NSString stringWithFormat:@"%@#%@#%@#%@#%@", appVersion, platform, [OpenUDID value], [CommonMethod machine], deviceVersion];
    NSString *info = [NSString stringWithFormat:@"%@#%@#%@#%@#%@", appVersion, platform, [NSString getUDID], [CommonMethod machine], deviceVersion];
    NSLog(@"appInfo:%@",info);
    
    return info;
}

+ (NSString *)machine
{
    size_t size;
    
    // Set 'oldp' parameter to NULL to get the size of the data
    // returned so we can allocate appropriate amount of space
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    // Allocate the space to store name
    char *name = malloc(size);
    
    // Get the platform name
    sysctlbyname("hw.machine", name, &size, NULL, 0);
    
    // Place name into a string
    NSString *machine = [NSString stringWithCString:name];
    
    // Done with this
    free(name);
    
    //iPhone
    if ([machine isEqualToString:@"iPhone1,1"]) return @"iPhone 2G (A1203)";
    else if ([machine isEqualToString:@"iPhone1,2"]) return @"iPhone3G";
    else if ([machine isEqualToString:@"iPhone2,1"]) return @"iPhone3GS";
    else if ([machine isEqualToString:@"iPhone3,1"]) return @"iPhone4";
    else if ([machine isEqualToString:@"iPhone3,2"]) return @"iPhone4";
    else if ([machine isEqualToString:@"iPhone3,3"]) return @"iPhone4";
    else if ([machine isEqualToString:@"iPhone4,1"]) return @"iPhone4S";
    else if ([machine isEqualToString:@"iPhone5,1"]) return @"iPhone5";
    else if ([machine isEqualToString:@"iPhone5,2"]) return @"iPhone5";
    else if ([machine isEqualToString:@"iPhone5,3"]) return @"iPhone5c";
    else if ([machine isEqualToString:@"iPhone5,4"]) return @"iPhone5c";
    else if ([machine isEqualToString:@"iPhone6,1"]) return @"iPhone5s";
    else if ([machine isEqualToString:@"iPhone6,2"]) return @"iPhone5s";
    else if ([machine isEqualToString:@"iPhone7,1"]) return @"iPhone6 Plus";
    else if ([machine isEqualToString:@"iPhone7,2"]) return @"iPhone6";
    else if ([machine isEqualToString:@"iPhone8,1"]) return @"iPhone6s";
    //iPod Touch
    else if ([machine isEqualToString:@"iPod1,1"]) return @"iPod Touch";
    else if ([machine isEqualToString:@"iPod2,1"]) return @"iPod Touch 2";
    else if ([machine isEqualToString:@"iPod3,1"]) return @"iPod Touch 3";
    else if ([machine isEqualToString:@"iPod4,1"]) return @"iPod Touch 4";
    else if ([machine isEqualToString:@"iPod5,1"]) return @"iPod Touch 5";
    //iPad
    else if ([machine isEqualToString:@"iPad1,1"]) return @"iPad";
    else if ([machine isEqualToString:@"iPad2,1"]) return @"iPad2";
    else if ([machine isEqualToString:@"iPad2,2"]) return @"iPad2";
    else if ([machine isEqualToString:@"iPad2,3"]) return @"iPad2";
    else if ([machine isEqualToString:@"iPad2,4"]) return @"iPad2";
    else if ([machine isEqualToString:@"iPad2,5"]) return @"iPad Mini 1";
    else if ([machine isEqualToString:@"iPad2,6"]) return @"iPad Mini 1";
    else if ([machine isEqualToString:@"iPad2,7"]) return @"iPad Mini 1";
    else if ([machine isEqualToString:@"iPad3,1"]) return @"iPad3";
    else if ([machine isEqualToString:@"iPad3,2"]) return @"iPad3";
    else if ([machine isEqualToString:@"iPad3,3"]) return @"iPad3";
    else if ([machine isEqualToString:@"iPad3,4"]) return @"iPad4";
    else if ([machine isEqualToString:@"iPad3,5"]) return @"iPad4";
    else if ([machine isEqualToString:@"iPad3,6"]) return @"iPad4";
    else if ([machine isEqualToString:@"iPad4,1"]) return @"iPad air";
    else if ([machine isEqualToString:@"iPad4,2"]) return @"iPad air";
    else if ([machine isEqualToString:@"iPad4,3"]) return @"iPad air";
    else if ([machine isEqualToString:@"iPad4,4"]) return @"iPad mini 2";
    else if ([machine isEqualToString:@"iPad4,5"]) return @"iPad mini 2";
    else if ([machine isEqualToString:@"iPad4,6"]) return @"iPad mini 2";
    else if ([machine isEqualToString:@"iPad4,7"]) return @"iPad mini 3";
    else if ([machine isEqualToString:@"iPad4,8"]) return @"iPad mini 3";
    else if ([machine isEqualToString:@"iPad4,9"]) return @"iPad mini 3";
    else if ([machine isEqualToString:@"iPad5,3"]) return @"iPad air 2";
    else if ([machine isEqualToString:@"iPad5,4"]) return @"iPad air 2";
    else if ([machine isEqualToString:@"iPhone Simulator"] || [machine isEqualToString:@"x86_64"]) return @"iPhone Simulator";
    else return machine;
}

+ (HttpResponseType)isHttpResponseSuccess:(id)response {
    if (![CommonMethod isKindOfDictionary:response]) {
        return HttpResponseTypeError;
    }
    
    id resultCode = [response objectForKey:@"status"];
    if (![CommonMethod isKindOfNSNumber:resultCode]) {
        return HttpResponseTypeError;
    }
    NSNumber *code = (NSNumber *)resultCode;
    if ([code intValue] == 1) {//接口调用成功
        return HttpResponseTypeSuccess;
    }else {//接口异常
        return HttpResponseTypeError;
    }
}

+ (NSInteger)getUserInfoCompletionRate{
    NSInteger rate = 0;
    UserModel *model = [DataModelInstance shareInstance].userModel;
    if(model.image.length){
        rate += 10;
    }
    if(model.realname.length){
        rate += 10;
    }
    if(model.company.length){
        rate += 10;
    }
    if(model.position.length){
        rate += 10;
    }
    if(model.industry.length){
        rate += 10;
    }
    if(model.worktime.length){
        rate += 10;
    }
    if(model.address.length){
        rate += 10;
    }
    if(model.remark.length){
        rate += 10;
    }
    if(model.phone.length > 0){
        rate += 10;
    }
    if(model.email.length > 0){
        rate += 5;
    }
    if(model.weixin.length > 0){
        rate += 5;
    }
    if(rate>100){
        rate = 100;
    }
    return rate;
}

+ (BOOL)getUserCanIdentify{
    UserModel *model = [DataModelInstance shareInstance].userModel;
    if(!model.realname.length){
        return NO;
    }else if(!model.company.length){
        return NO;
    }else if(!model.position.length){
        return NO;
    }else if(!model.image.length){
        return NO;
    }
    return YES;
}

+ (BOOL)getUserCanPublishTopicOrReview{
    UserModel *model = [DataModelInstance shareInstance].userModel;
    if(!model.realname.length){
        return NO;
    }else if(!model.company.length){
        return NO;
    }else if(!model.position.length){
        return NO;
    }else if(!model.image.length){
        return NO;
    }
    return YES;
}


+ (BOOL)getUserCanAddFriend{
    UserModel *model = [DataModelInstance shareInstance].userModel;
    if(!model.realname.length){
        return NO;
    }else if(!model.company.length){
        return NO;
    }else if(!model.position.length){
        return NO;
    }else if(!model.image.length){
        return NO;
    }else if(!model.goodjobs.count){
        return NO;
    }
    return YES;
}

@end
