//
//  ReportModel.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/5/4.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ReportModel.h"

@implementation ReportModel
- (void)parseDict:(NSDictionary *)dict{
    
    [self setValuesForKeysWithDictionary:dict];
    CGFloat viewHeight = 90;
    if (self.image.length <= 0) {
     CGFloat titleHeight = [NSHelper heightOfString:self.title font:FONT_SYSTEM_SIZE(17) width:WIDTH-32];
        CGFloat lineHeight = [UIFont systemFontOfSize:17.0].lineHeight;
        NSInteger  lineCount = titleHeight / lineHeight;
        if (lineCount > 25) {
          self.cellHeight = 70;
        }else{
            self.cellHeight = titleHeight + 24;
        }
        
    }else{
       self.cellHeight = viewHeight;
    }
    
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
@end
