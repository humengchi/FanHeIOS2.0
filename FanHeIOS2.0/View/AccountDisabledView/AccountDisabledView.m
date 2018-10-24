//
//  AccountDisabledView.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/9/21.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "AccountDisabledView.h"

@interface AccountDisabledView ()

@property (nonatomic, weak) IBOutlet UILabel    *phoneLabel;

@end

@implementation AccountDisabledView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib{
    [super awakeFromNib];
    [CommonMethod viewAddGuestureRecognizer:self.phoneLabel tapsNumber:1 withTarget:self withSEL:@selector(callPhone)];
}

- (void)callPhone{
    NSString *str = [NSString stringWithFormat:@"tel:021-65250669"];
    UIWebView *callWebView = [[UIWebView alloc]init];
    
    [callWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
    
    [[UIApplication sharedApplication].keyWindow addSubview:callWebView];
    
    [self removeFromSuperview];
}

- (IBAction)removeFromSuperviewButtonClicked:(id)sender{
    [self removeFromSuperview];
}

@end
