//
//  myView.m
//  crop
//
//  Created by ddapp on 16/4/13.
//  Copyright © 2016年 techinone. All rights reserved.
//

#import "myView.h"

@implementation myView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)btnAction:(UIButton *)sender {
    
    
    if ([_myViewDelegate respondsToSelector:@selector(btnActionWithTag:)]) {
        
        
        [_myViewDelegate  btnActionWithTag:sender.tag];
    }
    
}

@end
