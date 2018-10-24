//
//  NSDate+SHDQ.m
//  ChannelPlus
//
//  Created by Peter on 14/12/14.
//  Copyright (c) 2014年 Peter. All rights reserved.
//

#import "NSDate+SHDQ.h"
#include <sys/sysctl.h>

@implementation NSDate (SHDQ)

+ (NSString *)lastDayBeijingTimeString:(NSString *)format {
    NSDate *lastDateByLocal = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:[NSDate date]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone* GTMzone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [dateFormatter setTimeZone:GTMzone];
    [dateFormatter setDateFormat:kTimeFormat];
    NSString *lastDateStrByGTM = [dateFormatter stringFromDate:lastDateByLocal];
    NSDate *lastDateByGTM = [NSDate dateFromString:lastDateStrByGTM format:kTimeFormat];
    NSDate *beijingDate = [NSDate dateWithTimeInterval:8*60*60 sinceDate:lastDateByGTM];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    
    return [dateFormatter stringFromDate:beijingDate];
}
+ (NSString *)currentBeijingTimeString:(NSString *)format {
    NSDate *currentDateByLocal = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone* GTMzone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [dateFormatter setTimeZone:GTMzone];
    [dateFormatter setDateFormat:kTimeFormat];
    NSString *currentDateStrByGTM = [dateFormatter stringFromDate:currentDateByLocal];
    NSDate *currentDateByGTM = [NSDate dateFromString:currentDateStrByGTM format:kTimeFormat];
    NSDate *beijingDate = [NSDate dateWithTimeInterval:8*60*60 sinceDate:currentDateByGTM];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    
    return [dateFormatter stringFromDate:beijingDate];
}
+ (NSString *)nextDayBeijingTimeString:(NSString *)format {
    NSDate *nextDay = [NSDate dateWithTimeInterval:24*60*60 sinceDate:[NSDate date]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone* GTMzone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [dateFormatter setTimeZone:GTMzone];
    [dateFormatter setDateFormat:kTimeFormat];
    NSString *nextDateStrByGTM = [dateFormatter stringFromDate:nextDay];
    NSDate *nextDateByGTM = [NSDate dateFromString:nextDateStrByGTM format:kTimeFormat];
    NSDate *beijingDate = [NSDate dateWithTimeInterval:8*60*60 sinceDate:nextDateByGTM];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    
    return [dateFormatter stringFromDate:beijingDate];
}

+ (NSDate*)lastMonth:(NSDate*)currentDate{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:currentDate];
    [components setMonth:([components month] - 1)];
    return [cal dateFromComponents:components];
}

+ (NSString *)lastDayTimeString:(NSString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:format];
    
    NSDate *lastDay = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:[NSDate date]];
    
    return [dateFormatter stringFromDate:lastDay];
}

+ (NSString *)currentTimeString:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:format];
    
    return [formatter stringFromDate:[NSDate date]];
}

+ (NSString *)nextDayTimeString:(NSString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:format];
    
    NSDate *nextDay = [NSDate dateWithTimeInterval:24*60*60 sinceDate:[NSDate date]];
    
    return [dateFormatter stringFromDate:nextDay];
}

+ (NSTimeInterval)dateStringToLong:(NSString *)dateString {
    
   NSDate *date = [self dateFromString:dateString format:kTimeFormatLong];
    
    return [date timeIntervalSince1970];
}


+ (NSString*)weekdayStringFromDate:(NSDate*)inputDate {
    
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    
    [calendar setTimeZone: timeZone];
    
    NSCalendarUnit calendarUnit = NSWeekdayCalendarUnit;
    
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:inputDate];
    
    return [weekdays objectAtIndex:theComponents.weekday];
    
}

//输入的日期字符串形如：@"1992-05-21 13:08:08"

+ (NSDate *)dateFromString:(NSString *)dateString format:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat: format];
    
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    
    return destDate;
}

+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:format];
    
    NSString *destDateString = [dateFormatter stringFromDate:date];
    
    return destDateString;
}


+ (NSString *)stringTimeToFormatString:(NSString *)timeString fromFormat:(NSString *)fromFormat toFormat:(NSString *)toFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:toFormat];    
    NSDate *date =[NSDate dateFromString:timeString format:fromFormat];
    
    return [formatter stringFromDate:date];
}


+ (NSDictionary *)getCalendarRange:(NSDate *)date format:(NSString *)format calendarUnit:(NSCalendarUnit)calendarUnit beginValueKey:(NSString *)beginValueKey endValueKey:(NSString *)endValueKey
{
    if (date == nil) {
        date = [NSDate date];
    }
    double interval = 0;
    NSDate *beginDate = nil;
    NSDate *endDate = nil;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];//设定周一为周首日
    
    
    BOOL ok = [calendar rangeOfUnit:calendarUnit startDate:&beginDate interval:&interval forDate:date];
    //分别修改为 NSDayCalendarUnit NSWeekCalendarUnit NSYearCalendarUnit
    if (ok) {
        endDate = [beginDate dateByAddingTimeInterval:interval-1];
        
        for (int i = 0; i < 7  ; i++) {
            
            NSDateComponents *weekBeforeDateComponents = [[NSDateComponents alloc] init];
            
            weekBeforeDateComponents.day = i;
            
//            NSDate *vDayShoppingDay = [[NSCalendar currentCalendar]
//                                       dateByAddingComponents:weekBeforeDateComponents
//                                       toDate:beginDate
//                                       options:0];
            
            
            NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
            [myDateFormatter setDateFormat:format];
         
//            NSString *beginValue = [myDateFormatter stringFromDate:vDayShoppingDay];
            
        }
        
    }else {
        return nil;
    }
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    [myDateFormatter setDateFormat:format];
    
    NSString * beginValue = [myDateFormatter stringFromDate:beginDate];
    NSString * endValue = [myDateFormatter stringFromDate:endDate];
    
    
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:beginValueKey, beginValue, endValueKey, endValue, nil];
}



+ (NSArray *)getWeekDays:(NSDate *)date beginDay:(int)beginDay format:(NSString *)format
{
    if (date == nil) {
        date = [NSDate date];
    }
    double interval = 0;
    NSDate *beginDate = nil;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:beginDay];//设定周一为周首日
    
    BOOL ok = [calendar rangeOfUnit:NSCalendarUnitWeekOfMonth startDate:&beginDate interval:&interval forDate:date];
    if (ok) {
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (int i = 0; i < 7  ; i++) {
            
            NSDateComponents *weekBeforeDateComponents = [[NSDateComponents alloc] init];
            
            weekBeforeDateComponents.day = i;
            
            NSDate *dayDate = [[NSCalendar currentCalendar]
                                       dateByAddingComponents:weekBeforeDateComponents
                                       toDate:beginDate
                                       options:0];
            
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:format];
            
            NSString *day = [dateFormatter stringFromDate:dayDate];
            
            [array addObject:day];
            
        }
        
        
        return array;
    }else {
        return nil;
    }
    
    return nil;
}



//根据 day 获取 是第几周
+ (NSNumber *)getWeekNumber:(NSString *)day
{
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];

    unsigned units  = NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit | NSWeekOfYearCalendarUnit;
    NSDateComponents *_comps = [calendar components:units fromDate:[NSDate dateFromString:day format:kShortTimeFormat]];
    
    return @([_comps weekOfYear]);
}

//相差多少秒后的时间
+ (NSDate *)getDate:(NSDate *)date seconds:(NSInteger)seconds{
    NSDate *retDate = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kTimeFormat];
    retDate = [NSDate dateWithTimeInterval:seconds sinceDate:date];
    return retDate;
}


//type: 1、前一天   2、前一小时  3、前一分钟  4、前一秒
+ (NSDate *)getPreDate:(NSDate *)date type:(int)type{
    NSDate *retDate = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kTimeFormat];
    if (type == 1) {
        retDate = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:date];
    } else if (type == 2) {
        retDate = [NSDate dateWithTimeInterval:-60*60 sinceDate:date];
    } else if (type == 3) {
        retDate = [NSDate dateWithTimeInterval:-60 sinceDate:date];
    } else {
        retDate = [NSDate dateWithTimeInterval:-1 sinceDate:date];
    }
    return retDate;
}

//type: 1、后一天   2、后一小时  3、后一分钟  4、后一秒
+ (NSDate *)getNextDate:(NSDate *)date type:(int)type {
    NSDate *retDate = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kTimeFormat];
    if (type == 1) {
        retDate = [NSDate dateWithTimeInterval:24*60*60 sinceDate:date];
    } else if (type == 2) {
        retDate = [NSDate dateWithTimeInterval:60*60 sinceDate:date];
    } else if (type == 3) {
        retDate = [NSDate dateWithTimeInterval:60 sinceDate:date];
    } else {
        retDate = [NSDate dateWithTimeInterval:1 sinceDate:date];
    }
    return retDate;
}

//计算与当前时间 相隔 天数的 日期
+ (NSDate *)getDateByDistDays:(NSDate *)date distDays:(NSInteger )distDays
{
    NSDateComponents *weekBeforeDateComponents = [[NSDateComponents alloc] init];
    
    weekBeforeDateComponents.day = distDays;
    
     return  [[NSCalendar currentCalendar]
                       dateByAddingComponents:weekBeforeDateComponents
                       toDate:date
                       options:0];

}

//计算与当前时间 相隔 月数的 日期
+ (NSDate *)getDateByDistMonths:(NSDate *)date distMonths:(NSInteger )distMonths
{
    NSDateComponents *weekBeforeDateComponents = [[NSDateComponents alloc] init];
    
    weekBeforeDateComponents.month = distMonths;
    
    return  [[NSCalendar currentCalendar]
             dateByAddingComponents:weekBeforeDateComponents
             toDate:date
             options:0];
}

//根据当前时间 计算多少天以内的日期
+ (NSArray*)getAllDatesByCurrentDate:(NSDate*)date days:(NSInteger)days
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(int i = 0; i < days; i++){
        [array addObject:[self getDateByDistDays:date distDays:-i]];
    }
    return array;
}

//根据开始时间和结束时间， 计算区间以内的日期
+ (NSArray*)getAllDatesByBeginDate:(NSDate*)beginDate endDate:(NSDate*)endDate
{
    int days = [self daysAwayFrom:endDate dateSecond:beginDate];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(int i = 0; i <= days; i++){
        [array addObject:[self getDateByDistDays:beginDate distDays:i]];
    }
    return array;
}

//计算NSDate是否为今天的算法，无需使用calendar接口，无需format为字符串，兼容时区
+ (BOOL)isToday:(NSDate *)date
{
    double timezoneFix = [NSTimeZone localTimeZone].secondsFromGMT;
    if ((int)(([[NSDate date] timeIntervalSince1970] + timezoneFix)/(24*3600)) - (int)(([date timeIntervalSince1970] + timezoneFix)/(24*3600)) == 0) {
        return YES;
    } else {
        return NO;
    }
}

//计算两个NSDate是否为同一天
+ (BOOL)isTheSameDay:(NSDate *)dateFirst dateSecond:(NSDate *)dateSecond {
    double timezoneFix = [NSTimeZone localTimeZone].secondsFromGMT;
    if ((int)(([dateFirst timeIntervalSince1970] + timezoneFix)/(24*3600)) - (int)(([dateSecond timeIntervalSince1970] + timezoneFix)/(24*3600)) == 0) {
        return YES;
    } else {
        return NO;
    }
}

//计算两个NSDate相差多少月
+ (int)monthsAwayFrom:(NSDate *)dateFirst dateSecond:(NSDate *)dateSecond{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:dateFirst toDate:dateSecond options:0];
    int month = (int)(comps.year*12 + comps.month);
    return month;
}

//计算NSDate距离今天相差几天
+ (int)daysAwayFromToday:(NSDate *)date {
    double timezoneFix = [NSTimeZone localTimeZone].secondsFromGMT;
    return (int)(([date timeIntervalSince1970] + timezoneFix)/(24*3600)) - (int)(([[NSDate date] timeIntervalSince1970] + timezoneFix)/(24*3600));
}

//计算两个NSDate相差多少天
+ (int)daysAwayFrom:(NSDate *)dateFirst dateSecond:(NSDate *)dateSecond {
    double timezoneFix = [NSTimeZone localTimeZone].secondsFromGMT;
    return (int)(([dateFirst timeIntervalSince1970] + timezoneFix)/(24*3600)) - (int)(([dateSecond timeIntervalSince1970] + timezoneFix)/(24*3600));
}

//计算两个NSDate相差多少秒 精确到1秒
+ (int)secondsAwayFrom:(NSDate *)dateFirst dateSecond:(NSDate *)dateSecond {
    return (int)([dateFirst timeIntervalSince1970] - [dateSecond timeIntervalSince1970]);
}

//计算两个NSDate相差多少毫秒
+ (int)millisecondsAwayFrom:(NSDate *)dateFirst dateSecond:(NSDate *)dateSecond {
    return (int)([dateFirst timeIntervalSince1970]*1000 - [dateSecond timeIntervalSince1970]*1000);
}

//比较两个NSString的时间(datefirst 比datesecond 早)
+ (BOOL)daysAwayFromString:(NSString *)dateFirst dateSecondString:(NSString *)dateSecond
{
    NSDate *firstDate = [self dateFromString:dateFirst format:kShortTimeFormat];
    NSDate *secondDate = [self dateFromString:dateSecond format:kShortTimeFormat];
    if([self daysAwayFrom:firstDate dateSecond:secondDate] < 0){
        return YES;
    }
    return NO;
}

//判断是否是今年
+(BOOL)isCurrentYear:(NSDate*)date{
    if([[self currentTimeString:kTimeFormatYear] isEqualToString:[self stringFromDate:date format:kTimeFormatYear]]){
        return YES;
    }else{
        return NO;
    }
}

//获取当前月的天数
+ (int)getCurrentMonthDays
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSRange range = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:[NSDate date]];
    
    return (int)range.length;
}

//根据时间戳获取系统对应时区的时间字符串
+ (NSString *)getSystemDateStrByTimeStampSince1970:(NSNumber *)timeStamp {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp.doubleValue/1000];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSString *dateStr = [NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:interval]];
    return [dateStr substringToIndex:dateStr.length-6];
    ;
}

// 获取系统开机时间单位毫秒
/*
#include <mach/mach_time.h>
+ (long long) getSystemUptimeByMillisecond {
    const int64_t kOneMillion = 1000 * 1000;
    static mach_timebase_info_data_t s_timebase_info;
    if (s_timebase_info.denom == 0) {
        (void) mach_timebase_info(&s_timebase_info);
    }
    return (long long)((mach_absolute_time() * s_timebase_info.numer) / (kOneMillion * s_timebase_info.denom));
}
*/

+ (time_t)getSystemUptimeByMillisecond {
    struct timeval boottime;
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    size_t size = sizeof(boottime);
    time_t now;
    time_t uptime = -1;
    (void)time(&now);
    if (sysctl(mib, 2, &boottime, &size, NULL, 0) != -1 && boottime.tv_sec != 0) {
        uptime = now - boottime.tv_sec;
    }
    return uptime * 1000;
}

//时间显示规则
+ (NSString*)getDateTimeStr:(NSString*)dateTime style:(STYLE)style{
    NSString *resultStr;
    NSDate *date = [self dateFromString:dateTime format:kTimeFormat];
    switch (style) {
        case STYLE_1:{
            if([self secondsAwayFrom:[NSDate date] dateSecond:date] < 60*60){//xx分钟前
                resultStr = [NSString stringWithFormat:@"%d分钟前", (int)[self secondsAwayFrom:[NSDate date] dateSecond:date]/60+1];
            }else if([self secondsAwayFrom:[NSDate date] dateSecond:date] < 24*60*60){//xx小时前
                resultStr = [NSString stringWithFormat:@"%d小时前", (int)[self secondsAwayFrom:[NSDate date] dateSecond:date]/60/60];
            }else if([self secondsAwayFrom:[NSDate date] dateSecond:date] < 3*24*60*60){//xx小时前
                resultStr = [NSString stringWithFormat:@"%d天前", (int)[self secondsAwayFrom:[NSDate date] dateSecond:date]/60/60/24];
            }else if ([self isCurrentYear:date]){
                resultStr = [self stringFromDate:date format:KMDHMFormat];
            }else{
                resultStr = [self stringFromDate:date format:KNewTimeFormat];
            }
        }
            break;
        case STYLE_2:{
            resultStr = [self stringFromDate:date format:@"YYYY/MM/dd EEEE hh/mm"];
        }
            break;
        case STYLE_3:{
            resultStr = [self stringFromDate:date format:@"YYYY/MM/dd EEEE"];
        }
            break;
        case STYLE_4:{
            resultStr = [self stringFromDate:date format:@"yyyy/MM-dd HH:mm"];
        }
            break;
            
        default:
            break;
    }
    return  resultStr;
}

//if([self isToday:date]){//09:30
//    resultStr = [self stringFromDate:date format:kHHMMFormat];
//}else if ([self daysAwayFromToday:date] == 1){//昨天 09:12
//    resultStr = [NSString stringWithFormat:@"昨天 %@",[self stringFromDate:date format:kHHMMFormat]];
//}else if ([self isCurrentYear:date]){//05/12 09:12
//    resultStr = [self stringFromDate:date format:KMDHMFormat];
//}else{
//    resultStr = [self stringFromDate:date format:KNewTimeFormat];
//}
@end
