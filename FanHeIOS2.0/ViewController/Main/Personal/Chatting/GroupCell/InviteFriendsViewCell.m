//
//  InviteFriendsViewCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/8/18.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "InviteFriendsViewCell.h"

@implementation InviteFriendsViewCell
- (void)tranferInterChartModel:(ChartModel *)model{
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
    self.nameLabel.text = model.realname;
    self.sideLAbel.text = [NSString stringWithFormat:@"%@%@",model.company,[CommonMethod paramStringIsNull:model.position]];
    if (self.indexPath.section == 0) {
        [self.delectBtn setTitle:@"群主" forState:UIControlStateNormal];
        [self.delectBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [self.delectBtn setTitleColor:[UIColor colorWithHexString:@"666666"] forState:UIControlStateNormal];
        [self.delectBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }else{
        [self.delectBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    }
    self.delectBtn.hidden = !self.isOwer;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.coverImageView.layer.cornerRadius = 18;
    self.coverImageView.layer.masksToBounds = YES;
    // Initialization code
}

- (IBAction)delectAction:(UIButton *)sender {
    if (self.indexPath.section != 0) {
    [self.inviteFriendsViewCellDelect delectGroupFriends:self.indexPath];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
