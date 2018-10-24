//
//  CheckMoreDynamic.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/3/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "CheckMoreDynamic.h"

@implementation CheckMoreDynamic
- (IBAction)checkMoreDynamic:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CheckMoreDynamic" object:nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
