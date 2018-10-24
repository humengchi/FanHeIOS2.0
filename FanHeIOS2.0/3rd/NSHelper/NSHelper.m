//
//  Helper.m
//  PalmKitchen
//
//  Created by apple on 14-10-14.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "NSHelper.h"

@implementation NSHelper
//按比例缩放，size是你要把图显示到多大区域
+(UIImage  *)imageCompressFitSizeScale :(UIImage  *)sourceImage  targetSize :(CGSize)size {
    UIImage  * newImage =  nil ;
    CGSize imageSize = sourceImage .size ;
    CGFloat width = imageSize .width ;
    CGFloat height = imageSize .height ;
    CGFloat targetWidth = size .width ;
    CGFloat targetHeight = size .height ;
    CGFloat  scaleFactor =  0 ;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0 ,  0);
    if (CGSizeEqualToSize(imageSize,size)==  NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor> heightFactor){
            scaleFactor = widthFactor;
        }else {
        scaleFactor = heightFactor;
    }
scaledWidth =  width  * scaleFactor;
scaledHeight =  height  * scaleFactor;

if(widthFactor> heightFactor){
    thumbnailPoint .y  =(targetHeight - scaledHeight)*  0.5 ;
    
} else if (widthFactor <heightFactor){
    
    thumbnailPoint .x  =(targetWidth - scaledWidth)* 0.5 ;
}

UIGraphicsBeginImageContext(size);

CGRect thumbnailRect = CGRectZero;
thumbnailRect .origin  = thumbnailPoint;
thumbnailRect .size .width  = scaledWidth;
thumbnailRect .size .height  = scaledHeight;
[sourceImage  drawInRect :thumbnailRect];
newImage = UIGraphicsGetImageFromCurrentImageContext();
//    if （newImage ==  nil ）{
//    NSLog（@“scale image fail” ）;
//        }}
    UIGraphicsEndImageContext();
    return  newImage;
}
    return newImage;
}
/**
 *从图片中按指定的位置大小截取图片的一部分
 * UIImage image 原始的图片
 * CGRect rect 要截取的区域
 */
+ (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect {
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    return newImage;
}   

+(UIButton *)createButton:(CGRect)frame title:(NSString *)title unSelectImage:(UIImage *)unSelectImage selectImage:(UIImage *)selectImage target:(id)target selector:(SEL)selector
{
    
    UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:unSelectImage forState:UIControlStateNormal];
    [button setImage:selectImage forState:UIControlStateSelected];
       button.frame=frame;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
    button.titleLabel.font = FONT_SYSTEM_SIZE(16);
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
       return button;

}
+(UIButton *)createButton:(CGRect)frame title:(NSString *)title image:(UIImage *)image target:(id)target selector:(SEL)selector addttStr:(NSMutableAttributedString*)str{

    UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:image forState:UIControlStateNormal];
 
    button.frame=frame;
    CGRect newFrame=frame;
    newFrame.origin.y = 8;
    newFrame.size.height=frame.size.height - 8;
    newFrame.origin.x= frame.size.width*0.4;
    newFrame.size.width = frame.size.width - frame.size.width*0.4;
    UILabel * label=[[UILabel alloc]initWithFrame:newFrame];
    label.text=title;
   
    [button addSubview:label];
    label.font=[UIFont systemFontOfSize:14];
    label.backgroundColor=[UIColor clearColor];
 
    label.textAlignment = NSTextAlignmentLeft;
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    if (str.length != 0)
    {
        label.attributedText = str;
    }
    return button;
}

+(CGFloat)widthOfString:(NSString *)string font:(UIFont *)font height:(CGFloat)height{
    NSDictionary * dict=[NSDictionary dictionaryWithObject: font forKey:NSFontAttributeName];
    CGRect rect=[string boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    return rect.size.width;
}

+(CGFloat)heightOfString:(NSString *)string font:(UIFont *)font width:(CGFloat)width{
    CGRect bounds;
    NSDictionary * parameterDict=[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    bounds=[string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:parameterDict context:nil];
    return bounds.size.height;
}


+(CGFloat)widthOfString:(NSString *)string font:(UIFont *)font height:(CGFloat)height defaultWidth:(CGFloat)defaultWidth{
    
    CGSize constraint = CGSizeMake(2000.0f, height);
    CGSize size = [string sizeWithFont:font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    return size.width>defaultWidth?size.width:defaultWidth;
}

+(CGFloat)heightOfString:(NSString *)string font:(UIFont *)font width:(CGFloat)width defaultHeight:(CGFloat)defaultHeight{
    
    CGSize constraint = CGSizeMake(width, 2000.0f);
    CGSize size = [string sizeWithFont:font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    return size.height>defaultHeight?size.height:defaultHeight;
}

//判断字符串文字是否包含中文
+(BOOL)isContainsChinese:(NSString *)string {
    for(int i=0; i< [string length];i++){
        int a = [string characterAtIndex:i];
        if(a>0x4e00 && a<0x9fff) {
            return YES;
        }
    }
    return NO;
}

#pragma  mark - 获取当天的日期：年月日
+ (NSDictionary *)getTodayDate{
    //获取今天的日期
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = kCFCalendarUnitYear|kCFCalendarUnitMonth|kCFCalendarUnitDay;
    
    NSDateComponents *components = [calendar components:unit fromDate:today];
    NSString *year = [NSString stringWithFormat:@"%ld", (long)[components year]];
    NSString *month = [NSString stringWithFormat:@"%02ld", (long)[components month]];
    NSString *day = [NSString stringWithFormat:@"%02ld", (long)[components day]];
    
    NSMutableDictionary *todayDic = [[NSMutableDictionary alloc] init];
    [todayDic setObject:year forKey:@"year"];
    [todayDic setObject:month forKey:@"month"];
    [todayDic setObject:day forKey:@"day"];
    
    return todayDic;
    
}

//判断是否为浮点数
+(BOOL) isFloatNumber:(NSString *)numStr {
    NSString *numberRegex = @"^-?([1-9]\\d*\\.\\d*|0\\.\\d*[1-9]\\d*|0?\\.0+|0)$";
    NSPredicate *numberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",numberRegex];
    return [numberTest evaluateWithObject:numStr];
}

//判断是否为整数
+ (BOOL) isIntegerNumber:(NSString *)numStr {
    NSString *numberRegex = @"^-?[0-9]\\d*$";
    NSPredicate *numberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",numberRegex];
    return [numberTest evaluateWithObject:numStr];
}
+ (BOOL)checkEmail:(NSString *)email{
    
    //^(\\w)+(\\.\\w+)*@(\\w)+((\\.\\w{2,3}){1,3})$
    
    NSString *regex = @"^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\\.[a-zA-Z0-9_-]+)+$";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [emailTest evaluateWithObject:email];
    
}
//邮箱
+ (BOOL) justEmail:(NSString *)email{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

//手机号码验证
+ (BOOL) justMobile:(NSString *)mobile{
   /* 13x（0-9）
    145、147
    15x（0-3）、15x（5-9）
    170、176-178
    18x（0-9）*/
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(14[57])|(15[^4,\\D])|(17[0678])|(18[0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}


//车牌号验证
+ (BOOL) justCarNo:(NSString *)carNo{
    NSString *carRegex = @"^[\u4e00-\u9fa5]{1}[a-zA-Z]{1}[a-zA-Z_0-9]{4}[a-zA-Z_0-9_\u4e00-\u9fa5]$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    return [carTest evaluateWithObject:carNo];
}


//车型
+ (BOOL) justCarType:(NSString *)CarType{
    NSString *CarTypeRegex = @"^[\u4E00-\u9FFF]+$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CarTypeRegex];
    return [carTest evaluateWithObject:CarType];
}


//用户名
+ (BOOL) justUserName:(NSString *)name{
    NSString *userNameRegex = @"^[A-Za-z0-9]{6,20}+$";
    NSPredicate *userNamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",userNameRegex];
    BOOL B = [userNamePredicate evaluateWithObject:name];
    return B;
}


//密码
+ (BOOL) justPassword:(NSString *)passWord{
    NSString *passWordRegex = @"^[a-zA-Z0-9]{6,20}+$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    return [passWordPredicate evaluateWithObject:passWord];
}


//昵称
+ (BOOL) justNickname:(NSString *)nickname{
    NSString *nicknameRegex = @"^[\u4e00-\u9fa5]{4,8}$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",nicknameRegex];
    return [passWordPredicate evaluateWithObject:nickname];
}

//中文、英文、（）
+ (BOOL) justCompany:(NSString *)text{
    NSString *textRegex = @"^[\u4e00-\u9fa5a-zA-Z（）()]+$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",textRegex];
    return [passWordPredicate evaluateWithObject:text];
}

//中文、英文
+ (BOOL) justChinessAndEnlish:(NSString *)text{
    NSString *textRegex = @"^[\u4e00-\u9fa5a-zA-Z]+$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",textRegex];
    return [passWordPredicate evaluateWithObject:text];
}

//身份证号
+ (BOOL) justIdentityCard: (NSString *)identityCard{
    BOOL flag;
    if (identityCard.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:identityCard];
}

+ (UIView *)createrViewFrame:(CGRect)frame backColor:(NSString *)color{
    UIView *view = [[UIView alloc]initWithFrame:frame];
    view.backgroundColor = HEX_COLOR(color);
    return view;
}


//html
+ (NSAttributedString*)contentStringFromRawString:(NSString*)rawString
{
    if (!rawString || rawString.length == 0) return [[NSAttributedString alloc] initWithString:@""];
    
    NSMutableAttributedString *attrString = [NSHelper attributedStringFromHTML:rawString];
 //    NSMutableAttributedString *mutableAttrString = [[NSHelper emojiStringFromAttrString:attrString] mutableCopy];
//    [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, attrString.length)];
    [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, attrString.length)];
//
//    // remove under line style
    [attrString beginEditing];
    [attrString enumerateAttribute:NSUnderlineStyleAttributeName
                                  inRange:NSMakeRange(0, attrString.length)
                                  options:0
                               usingBlock:^(id value, NSRange range, BOOL *stop) {
                                   if (value) {
                                       [attrString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleNone) range:range];
                                   }
                               }];
    [attrString   endEditing];
    
    return attrString;
}

+ (NSMutableAttributedString *)attributedStringFromHTML:(NSString *)html
{
    // [NSAttributedAttributedString initWithData:options:documentAttributes:error:] is very slow
    // use DTCoreText instead
        if (![html hasPrefix:@"<"]) {
        html = [NSString stringWithFormat:@"<span>%@</span>", html]; // DTCoreText treat raw string as <p> element
    }
    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
    return [[NSMutableAttributedString alloc] initWithHTMLData:data options:@{ DTUseiOS6Attributes: @YES} documentAttributes:nil];
}

+ (CGFloat)rectHeightWithStr:(NSString *)content{
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[content dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSFontAttributeName:FONT_SYSTEM_SIZE(14) } documentAttributes:nil error:nil];
    CGRect fcRect = [attrStr boundingRectWithSize:CGSizeMake(WIDTH-32, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGFloat height = fcRect.size.height;
    if(height>60){
        return 60;
    }else{
        return height;
    }
}
+ (CGFloat)rectHeightWithStrHtml:(NSString *)html{
    NSString *str = [self filterHTML:html];
    CGFloat height = [NSHelper heightOfString:str font:FONT_SYSTEM_SIZE(14) width:WIDTH-32];
  
    if(height>60){
        return 60;
    }else{
        return height;
    }
}

+ (NSString *)filterHTML:(NSString *)html{
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
