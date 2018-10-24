//
//  UILabel+SHDQ.h
//  SHDQ
//
//  Created by Peter on 14-10-2.
//  Copyright (c) 2014年 com.shdq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (SHDQ)

+ (UILabel*)createLabel:(CGRect)frame font:(UIFont *)font bkColor:(UIColor *)bkColor textColor:(UIColor *)textColor;
+ (UILabel *)createrLabelframe:(CGRect)frame backColor:(UIColor *)color textColor:(UIColor *)textColor test:(NSString *)text font:(CGFloat)font number:(NSInteger)number nstextLocat:(NSTextAlignment )testLocat;
- (void)setParagraphText:(NSString*)text lineSpace:(CGFloat)space;
@end
