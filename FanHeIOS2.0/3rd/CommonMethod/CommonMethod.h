//
//  CommonMethod.h
//  ChannelPlus
//
//  Created by Peter on 14/12/15.
//  Copyright (c) 2014年 Peter. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "JSBadgeView.h"

typedef NS_ENUM(NSInteger, HttpResponseType) {
    HttpResponseTypeError = 0,//接口调用异常
    HttpResponseTypeSuccess = 1,//返回格式有效并接口调用成功
};


#define NUMBER(__OBJ) [NSNumber numberWithInt:__OBJ]
#define NUMBER_LONG(__OBJ) [NSNumber numberWithLong:__OBJ]
#define NUMBER_DOUBLE(__OBJ) [NSNumber numberWithDouble:__OBJ]


@interface CommonMethod : NSObject


+ (BOOL)isKindOfDictionary:(id)value;
+ (BOOL)isKindOfNSNumber:(id)value;
+ (BOOL)isKindOfArray:(id)value;
+ (BOOL)isKindOfString:(id)value;
+ (BOOL)stringIsNull:(NSString *)value;
+ (BOOL)webIsLink;
+ (BOOL)urlIsValid:(NSURL*)httpUrl;//判断url是否有效
+ (NSString *)paramStringIsNull:(NSString *)param;
+ (NSArray *)paramArrayIsNull:(NSArray *)param;
+ (NSDictionary *)paramDictIsNull:(NSDictionary *)param;
+ (NSNumber *)paramNumberIsNull:(NSNumber *)param;
+ (NSNumber *)paramNumberDoubleIsNull:(NSNumber *)param;


+ (void)updateTime:(dispatch_source_t )timer delaySecond:(double)delaySecond completion:(void(^)())completion;

+ (id)getViewFromNib:(NSString *)nibName;
+ (id)getVCFromNib:(Class)cls;
+ (id)getVCFromNib:(Class)cls nibName:(NSString *)nibName;
+ (UITapGestureRecognizer*)viewAddGuestureRecognizer:(UIView *)view tapsNumber:(int)tapsNumber withTarget:(id)target withSEL:(SEL)sel;


+ (void)changeViewSize:(UIView *)view endFrame:(CGRect)endFrame completion:(void(^)(BOOL finished))completion;
+ (void)changeViewSize:(UIView *)view startFrame:(CGRect)startFrame endFrame:(CGRect)endFrame completion:(void(^)(BOOL finished))completion;

+ (NSString *)machine;
+ (NSString *)getAppInfo;

+ (HttpResponseType)isHttpResponseSuccess:(id)response;

//个人资料完善率
+ (NSInteger)getUserInfoCompletionRate;

//点击认证，判断资料内：姓名、公司、职位是否完善
+ (BOOL)getUserCanIdentify;

//发起话题，发布评论，判断姓名、公司、职位、头像是否完善
+ (BOOL)getUserCanPublishTopicOrReview;

//添加好友时, 判断用户姓名、公司、职位、头像、擅长业务是否完善
+ (BOOL)getUserCanAddFriend;

@end
