//
//  ViewpointModel.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/15.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ViewpointModel.h"

@implementation ViewpointModel

- (void)parseDict:(NSDictionary *)dict{
    [self setValuesForKeysWithDictionary:dict];
    self.cellHeight = 110+[self rectHeightWithStr:self.content];
    NSString *style = [NSString stringWithFormat:@"%@",@"<head><meta name=\"viewport\" content=\"width=self.view.frame.size.width,initial-scale=1.0,user-scalable=0\"><style> body { margin:0; padding:0rem; border:0; font-size:100%; font-family:\"Helvetica Neue\",Helvetica,\"Hiragino Sans GB\",\"Microsoft YaHei\",Arial,sans-serif; vertical-align:baseline; word-break : normal; } p,div{ margin: 0; font-size: 0.875rem; line-height: 1.5; color: #41464E; word-break : normal; text-align:justify; text-justify:inter-word; } h1,h2,h3,h4,h5,h6 { margin: 0; font-size: 0.875rem; line-height: 1.5; color: #41464E; font-weight:bold; word-break : normal; text-align:justify; text-justify:inter-word; } img{ max-width: 100%; height: auto; object-fit:scale-down; } a { font-size: 0.875rem; line-height: 1.5; color: #4393E2; padding:0 0.3125rem; text-decoration: none; -webkit-tap-highlight-color:rgba(0,0,0,0); }width:100% !important;}</style></head>"];
    if([[self.content lowercaseString] hasPrefix:@"<p "] || [[self.content lowercaseString] hasPrefix:@"<p>"]){
        self.content = [NSString stringWithFormat:@"%@%@", style, self.content];
    }else{
        self.content = [NSString stringWithFormat:@"%@<p>%@</p>", style, self.content];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (CGFloat)rectHeightWithStr:(NSString *)htmlString{
    NSString *str = [htmlString filterHTML];
    CGFloat lineHeight = [FONT_SYSTEM_SIZE(15) lineHeight];
    CGFloat height = [NSHelper heightOfString:str font:FONT_SYSTEM_SIZE(15) width:WIDTH-75];
    
    height += ((NSInteger)(height/lineHeight))*4;
    NSString *subStr = [htmlString lowercaseString];
    int count = 0;
    NSRange range = [subStr rangeOfString:@"<br"];
    while (range.location != NSNotFound) {
        count++;
        subStr = [subStr substringFromIndex:range.location + range.length];
        range = [subStr rangeOfString:@"<br"];
    }
    if(count>2){
        height += (lineHeight+4)*2;
    }else{
        height += (lineHeight+4)*count;
    }
    if(height>lineHeight*4){
        return lineHeight*4+12;//84
    }else{
        return height;
    }
}


@end
