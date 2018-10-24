//
//  AlreadHaveCofferView.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/11/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "AlreadHaveCofferView.h"

@implementation AlreadHaveCofferView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)checkGetCoffer:(UIButton *)sender {
    if(self.checkGetCofferDetail){
        self.checkGetCofferDetail();
    }
    [self removeFromSuperview];
}
- (IBAction)cancleCofferView:(id)sender {
    [self removeFromSuperview];

}

@end
