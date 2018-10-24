//
//  HelpView.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/24.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "HelpView.h"

@implementation HelpView

- (void)awakeFromNib{
    [super awakeFromNib];
    [CALayer updateControlLayer:self.headerImageView.layer radius:22 borderWidth:0 borderColor:nil];
}

- (IBAction)clearChartHistory:(UIButton *)sender {
    if ([self.helpDelegate respondsToSelector:@selector(clearHistoryChart)]) {
        [self.helpDelegate clearHistoryChart];
    }
}

@end
