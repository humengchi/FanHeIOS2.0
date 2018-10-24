//
//  WorkHistoryDetailCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/2/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "WorkHistoryDetailCell.h"

@implementation WorkHistoryDetailCell
- (void)tranfrtWorkHistoryDetailCellModel:(UserModel *)model{
     [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
    self.headerImageView.layer.masksToBounds = YES; //没这句话它圆不起来
    self.headerImageView.layer.cornerRadius = 22; //设置图片圆角的尺度
    self.verfyIamgeView.hidden = model.usertype.integerValue != 9;
      self.registImageView.hidden = model.hasValidUser.integerValue != 1;
    self.nameLabel.text = model.realname;
    self.workYearLabel.text = model.colleaguestr;
    self.positionLabel.text = [NSString stringWithFormat:@"%@%@",model.company,model.position];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
