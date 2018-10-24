//
//  MyDynamicView.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/3/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "MyDynamicView.h"

@implementation MyDynamicView
- (void)updateDisplay:(BOOL)isHome{
    if (isHome) {
        self.statLabel.text = @"我的动态";
    }else{
        self.statLabel.text = @"Ta的动态";
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
