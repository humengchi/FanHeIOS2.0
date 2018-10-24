//
//  Helper.h
//  PalmKitchen
//
//  Created by apple on 14-10-14.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSHelper : NSObject
+(UIImage  *)imageCompressFitSizeScale :(UIImage  *)sourceImage  targetSize :(CGSize)size;
+ (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect;
+(UIButton *)createButton:(CGRect)frame title:(NSString *)title unSelectImage:(UIImage *)unSelectImage selectImage:(UIImage *)selectImage target:(id)target selector:(SEL)selector;

+(UIButton *)createButton:(CGRect)frame title:(NSString *)title image:(UIImage *)image  target:(id)target selector:(SEL)selector addttStr:(NSMutableAttributedString*)str;

//字符串文字的长度
+(CGFloat)widthOfString:(NSString *)string font:(UIFont*)font height:(CGFloat)height;

//字符串文字的高度
+(CGFloat)heightOfString:(NSString *)string font:(UIFont*)font width:(CGFloat)width;

//字符串文字的长度
+(CGFloat)widthOfString:(NSString *)string font:(UIFont *)font height:(CGFloat)height defaultWidth:(CGFloat)defaultWidth;

//字符串文字的高度
+(CGFloat)heightOfString:(NSString *)string font:(UIFont *)font width:(CGFloat)width defaultHeight:(CGFloat)defaultHeight;

//判断字符串文字是否包含中文
+(BOOL)isContainsChinese:(NSString *)string;

//获取今天的日期：年月日
+(NSDictionary *)getTodayDate;

//判断是否为浮点数
+ (BOOL) isFloatNumber:(NSString *)numStr;

//判断是否为整数
+ (BOOL) isIntegerNumber:(NSString *)numStr;

//邮箱
+ (BOOL) justEmail:(NSString *)email;

//手机号码验证
+ (BOOL) justMobile:(NSString *)mobile;

//车牌号验证
+ (BOOL) justCarNo:(NSString *)carNo;

//车型
+ (BOOL) justCarType:(NSString *)CarType;

//用户名
+ (BOOL) justUserName:(NSString *)name;

//密码
+ (BOOL) justPassword:(NSString *)passWord;

//昵称
+ (BOOL) justNickname:(NSString *)nickname;

//公司
+ (BOOL) justCompany:(NSString *)text;

//中文、英文
+ (BOOL) justChinessAndEnlish:(NSString *)text;

//身份证号
+ (BOOL) justIdentityCard: (NSString *)identityCard;

+ (UIView *)createrViewFrame:(CGRect)frame backColor:(NSString *)color;

//html
+ (NSAttributedString*)contentStringFromRawString:(NSString*)rawString;
+ (CGFloat)rectHeightWithStr:(NSString *)content;
+ (CGFloat)rectHeightWithStrHtml:(NSString *)html;
@end


