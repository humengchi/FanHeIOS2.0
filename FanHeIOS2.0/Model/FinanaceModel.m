//
//  FinanaceModel.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "FinanaceModel.h"

@implementation FinanaceModel

- (void)parseDict:(NSDictionary *)dict{
    [self setValuesForKeysWithDictionary:dict];
    
    self.model = [[PushTicpsmodle alloc] initWithDict:[CommonMethod paramDictIsNull:dict[@"reply"]]];
    [self rectHeightWithStr];
    
//    if([CommonMethod paramStringIsNull:self.model.content].length){
//        NSString *style = [NSString stringWithFormat:@"%@",@"<head><meta name=\"viewport\" content=\"width=self.view.frame.size.width,initial-scale=1.0,user-scalable=0\"><style> body { margin:0; padding:0rem; border:0; font-size:100%; font-family:\"Helvetica Neue\",Helvetica,\"Hiragino Sans GB\",\"Microsoft YaHei\",Arial,sans-serif; vertical-align:baseline; word-break : normal; } p{ margin: 0; font-size: 0.875rem; line-height: 1.5; color: #41464E; word-break : normal; text-align:justify; text-justify:inter-word; } h1,h2,h3,h4,h5,h6 { margin: 0; font-size: 0.875rem; line-height: 1.5; color: #41464E; font-weight:bold; word-break : normal; text-align:justify; text-justify:inter-word; } img{ max-width: 100%; height: auto; object-fit:scale-down; } a { font-size: 0.875rem; line-height: 1.5; color: #4393E2; padding:0 0.3125rem; text-decoration: none; -webkit-tap-highlight-color:rgba(0,0,0,0); }width:100% !important;}</style></head>"];
//        self.model.content = [NSString stringWithFormat:@"%@<p>%@</p>", style, self.model.content];
//    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (void)rectHeightWithStr{
    CGFloat height = 91;
    NSString *titleStr = self.title;
    CGFloat heigth1 = [NSHelper heightOfString:titleStr font:[UIFont systemFontOfSize:17] width:(WIDTH -32)];
    if (heigth1 > 22) {
        heigth1 = 41;
    }else{
        heigth1 = 21;
    }
    NSString *sideStr = self.model.content;
    if(sideStr.length > 0) {
        NSString *str = [sideStr filterHTML];
        CGFloat height2 = [NSHelper heightOfString:str font:FONT_SYSTEM_SIZE(14) width:WIDTH-32];
        height2 += ((NSInteger)height2)/17*4;
        if(height2>30){
            height2 = 40;
        }else{
            height2 = 20;
        }
        height += 62+height2;
    }
    self.cellHeight = height+heigth1;
}


@end
