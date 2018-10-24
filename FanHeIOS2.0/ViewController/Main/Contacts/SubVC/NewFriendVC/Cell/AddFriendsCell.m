//
//  AddFriendsCell.m
//  JinMai
//
//  Created by renhao on 16/5/20.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import "AddFriendsCell.h"

@implementation AddFriendsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.exchangeBtn.layer.cornerRadius = 11;
    self.exchangeBtn.layer.masksToBounds = YES;
    
    self.coverImageView.layer.masksToBounds = YES;
    self.coverImageView.layer.cornerRadius = 14.5;
}

+ (CGFloat)getCellHeight:(UserModel*)model{
    CGFloat height = 51;
    height += [NSHelper heightOfString:[NSString stringWithFormat:@"%@%@",model.company, model.position] font:FONT_SYSTEM_SIZE(14) width:WIDTH-141 defaultHeight:20];
    return height;
}

- (void)exchangeAddFriends:(ChartModel *)model{
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
    
    self.nameLabel.text = model.reason;
    NSString *position = [NSString stringWithFormat:@"%@%@",[CommonMethod paramStringIsNull:model.company],[CommonMethod paramStringIsNull:model.position]];
    if (position.length > 0) {
        self.positiLabel.text = position;
    }else{
        self.positiLabel.text = @"公司职位";
    }
    
    self.exchangeBtn.tag = self.index;
    if(model.status.integerValue == 0){
        [self.exchangeBtn setTitleColor:HEX_COLOR(@"d7d7d7") forState:UIControlStateNormal];
        [self.exchangeBtn setTitle:@"已发送" forState:UIControlStateNormal];
        self.exchangeBtn.backgroundColor = WHITE_COLOR;
        self.exchangeBtn.userInteractionEnabled = NO;
    }else{
        [self.exchangeBtn setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
        [self.exchangeBtn setTitle:@"加好友" forState:UIControlStateNormal];
        self.exchangeBtn.backgroundColor = kDefaultColor;
        self.exchangeBtn.userInteractionEnabled = YES;
    }
}


- (IBAction)exchangeCardBtn:(UIButton *)sender {
    if ([self.exchangeDelegate respondsToSelector:@selector(exchangeChatCard:)]){
        [self.exchangeDelegate exchangeChatCard:self.tag];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
