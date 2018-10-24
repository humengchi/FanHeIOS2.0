//
//  notChoseView.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/5/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "notChoseView.h"

@implementation notChoseView
- (IBAction)clearnAllChose:(id)sender {
    if ([self.notChoseViewDelegate respondsToSelector:@selector(clearAllChoseCondition)]) {
        [self.notChoseViewDelegate clearAllChoseCondition];
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
