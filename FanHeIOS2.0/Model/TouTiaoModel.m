//
//  TouTiaoModel.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/28.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "TouTiaoModel.h"

@implementation TouTiaoModel

- (void)parseDict:(NSDictionary *)dict{
    self.cellHeight = 179+38;
    self.modelArray = [NSMutableArray array];
    self.heightArray = [NSMutableArray array];
    NSInteger index = 0;
    for(NSDictionary *modelDict in dict[@"data"]){
        TalkFianaceModel *model = [[TalkFianaceModel alloc] initWithDict:modelDict];
        [self.modelArray addObject:model];
        CGFloat height = 0;
        if(index==0){
            height = [NSHelper heightOfString:model.title font:FONT_SYSTEM_SIZE(16) width:WIDTH-80];
            if(height>FONT_SYSTEM_SIZE(16).lineHeight*2){
                height = FONT_SYSTEM_SIZE(16).lineHeight*2;
            }
        }else{
            height = [NSHelper heightOfString:model.title font:FONT_SYSTEM_SIZE(16) width:WIDTH-108 defaultHeight:38];
            height += (height/FONT_SYSTEM_SIZE(16).lineHeight-1)*6;
            self.cellHeight += height+22;
        }
        [self.heightArray addObject:@(height)];
        index++;
    }
    self.sendtime = [CommonMethod paramStringIsNull:dict[@"sendtime"]];
    
}


@end
