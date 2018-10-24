//
//  GetMyselfCoffer.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/11/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "GetMyselfCoffer.h"

@implementation GetMyselfCoffer
- (void)ceraterTitleLabelShow:(BOOL)isMyself{
    if (isMyself) {
        self.titleLabel.text = @"你无法领取自己送出的人脉咖啡";
    }else{
         self.titleLabel.text = @"此咖啡已失效";
    }
    
}
- (IBAction)getMyselfOrNoCoffer:(UIButton *)sender {
      [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
