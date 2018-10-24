//
//  AttentionCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/29.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "AttentionCell.h"

@implementation AttentionCell
- (void)exchangeCardBtn:(ChartModel *)model type:(NSInteger)index{
    self.vipImageView.hidden = model.usertype.integerValue != 9;
    self.headerImageView.layer.masksToBounds = YES; //没这句话它圆不起来
    self.headerImageView.layer.cornerRadius = 15; //设置图片圆角的尺度
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
   
    NSString *position = [NSString stringWithFormat:@"%@%@",model.company,model.position];
    if (position.length > 0) {
         self.nameLabel.text = model.realname;
        self.postionLabel.text = position;
        self.realName.hidden = YES;
    }else{
        self.postionLabel.hidden = YES;
        self.nameLabel.hidden = YES;
        self.realName.text =  model.realname;
    }
  
    if (index == 1) {
        if (model.isattent.integerValue == 0) {
            [self.exchangeBtn setTitle:@"已关注" forState:UIControlStateNormal];
        }
    }else{
        if (model.isattent.integerValue == 0) {
            [self.exchangeBtn setBackgroundImage:[UIImage imageNamed:@"btn-register-countdown-off"] forState:UIControlStateNormal];
            [self.exchangeBtn setTitle:@"关注" forState:UIControlStateNormal];
            [self.exchangeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)EchangeBtnAction:(UIButton *)sender {
    if ([self.atteneionDelegate respondsToSelector:@selector(exchangeAttionAction:)]) {
        [self.atteneionDelegate exchangeAttionAction:self.index];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
