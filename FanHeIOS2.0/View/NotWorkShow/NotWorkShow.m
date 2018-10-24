//
//  NotWorkShow.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/9/6.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "NotWorkShow.h"

@implementation NotWorkShow

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)awakeFromNib{
    [super awakeFromNib];
    [CommonMethod viewAddGuestureRecognizer:self tapsNumber:1 withTarget:self withSEL:@selector(againGetDataAction)];
}
- (void)againGetDataAction{
    if(self.againGetData){
        self.againGetData();
    }
}

@end
