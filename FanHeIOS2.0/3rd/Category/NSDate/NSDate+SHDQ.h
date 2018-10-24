//
//  NSDate+SHDQ.h
//  ChannelPlus
//
//  Created by Peter on 14/12/14.
//  Copyright (c) 2014年 Peter. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kTimeFormatYear                      @"yyyy"
#define kTimeFormatMonth                     @"yyyy-MM"
#define kTimeFormatMonthChinese              @"yyyy年MM月"
#define kTimeFormatDateDay                   @"yyyy-MM-dd EEEE"
#define kTimeFormatChinese                   @"yyyy年MM月dd日"

#define kShortTimeFormat                     @"yyyy-MM-dd"
#define kTimeFormat                          @"yyyy-MM-dd HH:mm:ss"
#define kTimeFormat0                         @"yyyy-MM-dd HH:mm:ss.S"
#define kTimeFormat1                         @"yyyy-MM-dd HH:mm"
#define kTimeFormatLong                      @"HH:mm:ss.SSS"
#define kTimeFormatSmallLong                 @"yyyyMMddHHmmssSSS"
#define kTimeFormatSmallLong2                @"yyMMddHHmmssSSS"
#define kTimeFormatSmallLong3                @"yyyyMMddHHmmss"
#define kTimeFormatNOSpace                   @"yyyy-MM-dd_HH:mm:ss"

#define kTimeFormatZone                      @"yyyy-MM-dd HH:mm:ss zzz"

#define kHHMMFormat                          @"HH:mm"
#define kHHMMSSFormat                        @"HH:mm:ss"

#define KMDHMFormat                          @"MM-dd"
#define KNewTimeFormat                       @"yyyy-MM-dd"
#define HSystemTimew                         @"yyyy/MM-dd HH:mm"
typedef NS_ENUM(NSUInteger, STYLE){
    STYLE_1,
    STYLE_2,
    STYLE_3,
    STYLE_4
};

@interface NSDate (SHDQ)

+ (NSString *)lastDayBeijingTimeString:(NSString *)format;
+ (NSString *)currentBeijingTimeString:(NSString *)format;
+ (NSString *)nextDayBeijingTimeString:(NSString *)format;

+ (NSDate*)lastMonth:(NSDate*)currentDate;

+ (NSString *)lastDayTimeString:(NSString *)format;
+ (NSString *)currentTimeString:(NSString *)format;
+ (NSString *)nextDayTimeString:(NSString *)format;

+ (NSString*)weekdayStringFromDate:(NSDate*)inputDate;//星期一...
+ (NSDate *)dateFromString:(NSString *)dateString format:(NSString *)format;
+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format;

+ (NSString *)stringTimeToFormatString:(NSString *)timeString fromFormat:(NSString *)fromFormat toFormat:(NSString *)toFormat;

+ (NSDictionary *)getCalendarRange:(NSDate *)date format:(NSString *)format calendarUnit:(NSCalendarUnit)calendarUnit beginValueKey:(NSString *)beginValueKey endValueKey:(NSString *)endValueKey;

+ (NSTimeInterval)dateStringToLong:(NSString *)dateString;


/**
 *  根据指定时间获取 以 beginDay 为周首日的 一周的时间
 *
 *  @param date     @""
 *  @param beginDay 1:日, 2:一, 3:二...
 *  @param format
 *
 *  @return
 */
+ (NSArray *)getWeekDays:(NSDate *)date beginDay:(int)beginDay format:(NSString *)format;


//根据 day 获取 是第几周
+ (NSNumber *)getWeekNumber:(NSString *)day;

//相差多少秒后的时间
+ (NSDate *)getDate:(NSDate *)date seconds:(NSInteger)seconds;

//type: 1、前一天   2、前一小时  3、前一分钟  4、前一秒
+ (NSDate *)getPreDate:(NSDate *)date type:(int)type;

//type: 1、后一天   2、后一小时  3、后一分钟  4、后一秒
+ (NSDate *)getNextDate:(NSDate *)date type:(int)type;

//计算与当前时间 相隔 天数的 日期
+ (NSDate *)getDateByDistDays:(NSDate *)date distDays:(NSInteger )distDays;

//计算与当前时间 相隔 月数的 日期
+ (NSDate *)getDateByDistMonths:(NSDate *)date distMonths:(NSInteger )distMonths;

//根据当前时间 计算多少天以内的日期
+ (NSArray*)getAllDatesByCurrentDate:(NSDate*)date days:(NSInteger)days;

//根据开始时间和结束时间， 计算区间以内的日期
+ (NSArray*)getAllDatesByBeginDate:(NSDate*)beginDate endDate:(NSDate*)endDate;

//计算NSDate是否为今天(无需使用calendar接口，无需format为字符串，兼容时区)
+ (BOOL)isToday:(NSDate *)date;

//计算两个NSDate是否为同一天
+ (BOOL)isTheSameDay:(NSDate *)dateFirst dateSecond:(NSDate *)dateSecond;

//计算两个NSDate相差多少月
+ (int)monthsAwayFrom:(NSDate *)dateFirst dateSecond:(NSDate *)dateSecond;

//计算NSDate距离今天相差多少天
+ (int)daysAwayFromToday:(NSDate *)date;

//计算两个NSDate相差多少天
+ (int)daysAwayFrom:(NSDate *)dateFirst dateSecond:(NSDate *)dateSecond;

//计算两个NSDate相差多少秒
+ (int)secondsAwayFrom:(NSDate *)dateFirst dateSecond:(NSDate *)dateSecond;

//计算两个NSDate相差多少毫秒
+ (int)millisecondsAwayFrom:(NSDate *)dateFirst dateSecond:(NSDate *)dateSecond;

//比较两个NSString的时间
+ (BOOL)daysAwayFromString:(NSString *)dateFirst dateSecondString:(NSString *)dateSecond;

//判断是否是今年
+(BOOL)isCurrentYear:(NSDate*)date;

//获取当前月的天数
+ (int)getCurrentMonthDays;

//根据时间戳获取系统对应时区的时间字符串
+ (NSString *)getSystemDateStrByTimeStampSince1970:(NSNumber *)timeStamp;

// 获取当前时刻 距离 系统开机时间多少毫秒
+ (time_t) getSystemUptimeByMillisecond;

//时间显示规则
+ (NSString*)getDateTimeStr:(NSString*)dateTime style:(STYLE)style;

@end
