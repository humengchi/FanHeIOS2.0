//
//  PolicyShowView.m
//  JinMai
//
//  Created by 胡梦驰 on 16/3/23.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import "PolicyShowView.h"

@interface PolicyShowView ()

@property (nonatomic, weak) IBOutlet UIView *contentView;

@end

@implementation PolicyShowView


- (void)awakeFromNib{
    [super awakeFromNib];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (IBAction)closeView:(id)sender{
    [[self viewController] newThreadForAvoidButtonRepeatClick:sender];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [UIView animateWithDuration:0.5 animations:^{
        self.frame = CGRectMake(0, HEIGHT, WIDTH, HEIGHT);
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
