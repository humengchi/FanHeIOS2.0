//
//  ChangeGroupOwnerViewCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/8/29.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ChangeGroupOwnerViewCell.h"

@implementation ChangeGroupOwnerViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.coverImageView.layer.cornerRadius = 18;
    self.coverImageView.layer.masksToBounds = YES;
    // Initialization code
}
- (void)tranferInterChartModelChangeOwer:(ChartModel *)model{
    _model = model;
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
    self.nameLabel.text = model.realname;
    self.positionLabel.text = [NSString stringWithFormat:@"%@%@",model.company,[CommonMethod paramStringIsNull:model.position]];
}
- (IBAction)changeGroupOwerAction:(id)sender {
    [self.changeGroupOwnerViewCellDelect changeGroupOwer:_model];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
