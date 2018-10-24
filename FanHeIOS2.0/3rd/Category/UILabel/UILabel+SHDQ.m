//
//  UILabel+SHDQ.m
//  SHDQ
//
//  Created by Peter on 14-10-2.
//  Copyright (c) 2014年 com.shdq. All rights reserved.
//

#import "UILabel+SHDQ.h"

@implementation UILabel (SHDQ)

+ (UILabel*)createLabel:(CGRect)frame font:(UIFont *)font bkColor:(UIColor *)bkColor textColor:(UIColor *)textColor{
    UILabel *label  = [[UILabel alloc] initWithFrame:frame];
    label.font = font;
    label.backgroundColor = bkColor;
    label.textColor = textColor;
    return label;
}

+ (UILabel *)createrLabelframe:(CGRect)frame backColor:(UIColor *)color textColor:(UIColor *)textColor test:(NSString *)text font:(CGFloat)font number:(NSInteger)number nstextLocat:(NSTextAlignment )testLocat{
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    label.text = text;
    label.backgroundColor = color;
    label.textColor = textColor;
    label.textAlignment = testLocat;
    label.numberOfLines = number;
    label.font = [UIFont systemFontOfSize:font];
    return label;
}

- (void)setParagraphText:(NSString*)text lineSpace:(CGFloat)space{
    if(text == nil || text.length == 0){
        return;
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:space];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, text.length)];
    self.attributedText = attributedString;
    self.lineBreakMode = NSLineBreakByTruncatingTail;
}


@end
