//
//  ChangeInformationMsgCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/7/20.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ChangeInformationMsgCell.h"

@implementation ChangeInformationMsgCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)tranferChangeNotificationCellModel:(DynamicDetailModel *)model{
    self.headviewImage.tag = self.
    self.headviewImage.layer.masksToBounds = YES;
    self.headviewImage.layer.cornerRadius = self.headviewImage.frame.size.width/2.0;
    [self.headviewImage sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
       self.veryImageView.hidden = model.usertype.integerValue != 9;
    self.nameLabel.text = model.realname;
    self.changeMsgLabel.text = model.msg;
    self.timeLabel.text = model.created_at;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
