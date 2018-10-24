//
//  JobTextFile.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/11/4.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "JobTextFile.h"

@implementation JobTextFile

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
 */
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//       self.str = self.text;
//}


- (void) deleteBackward{
    [super deleteBackward];
    if (self.keyInputDelegate && [self.keyInputDelegate respondsToSelector:@selector(deleteBackwardJob)]) {
[self.keyInputDelegate deleteBackwardJob];
                self.index = 0;
    }
}

@end
