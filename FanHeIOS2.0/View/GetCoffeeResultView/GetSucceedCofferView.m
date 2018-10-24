
//
//  GetSucceedCofferView.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/11/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "GetSucceedCofferView.h"

@implementation GetSucceedCofferView
- (void)createrGetCofferCoverImage:(NSString *)imageUrl isMyGet:(BOOL)isMyGet{
    self.coverImageView.layer.cornerRadius = 10.0;
    self.coverImageView.layer.masksToBounds = YES;
    self.coverView.layer.cornerRadius = 10.0;
    self.coverView.layer.masksToBounds = YES;
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:KEqualWHImageDefault];
    if (isMyGet) {
        self.titleLabel.text = @"您已成功领取该咖啡";
    }
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:@"请凭此卡片到前台兑换咖啡！"];
    
    [AttributedStr addAttribute:NSForegroundColorAttributeName value:HEX_COLOR(@"E24943") range:NSMakeRange(3, 2)];
    [AttributedStr addAttribute:NSForegroundColorAttributeName value:HEX_COLOR(@"E24943") range:NSMakeRange(6, 2)];
    self.sideLabel.attributedText = AttributedStr;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)removeMyViewAction:(UIButton *)sender {
     [self removeFromSuperview];
}

@end
