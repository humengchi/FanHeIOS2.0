//
//  TopicModel.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/20.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "TopicModel.h"

@implementation TopicModel

- (void)parseDict:(NSDictionary *)dict{
    [self setValuesForKeysWithDictionary:dict];
    
    /*CGFloat viewHeight = 48;
    if([CommonMethod paramArrayIsNull:self.tagname].count){
        CGFloat start_X = 0;
        CGFloat start_Y = 0;
        for (int i=0; i < self.tagname.count; i++) {
            CGFloat strWidth = [NSHelper widthOfString:self.tagname[i] font:FONT_SYSTEM_SIZE(12) height:20]+16;
            if(start_X+strWidth>WIDTH-32){
                if(strWidth>WIDTH-32){
                    strWidth = WIDTH-32;
                }
                start_X = 0;
                start_Y += 26;
            }
            start_X += strWidth+6;
        }
        viewHeight += start_Y+30;
    }*/
    CGFloat viewHeight = 97;
    CGFloat titleHeight = [NSHelper heightOfString:self.title font:FONT_SYSTEM_SIZE(15) width:WIDTH-32];
    titleHeight += (NSInteger)(titleHeight/[FONT_SYSTEM_SIZE(15) lineHeight])*6;
    viewHeight += titleHeight;
    self.cellHeight = viewHeight;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

@end
