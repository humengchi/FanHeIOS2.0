//
//  ChoiceResultView.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/3/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ChoiceResultView.h"

@implementation ChoiceResultView

- (void)drawRect:(CGRect)rect {
    [CALayer updateControlLayer:self.layer radius:2.5 borderWidth:0.5 borderColor:HEX_COLOR(@"d9dadb").CGColor];
}

- (IBAction)choiceButtonClicked:(UIButton*)sender{
    if(self.ChoiceResultViewType){
        self.ChoiceResultViewType(sender.tag);
    }
    [self.superview removeFromSuperview];
}


@end
