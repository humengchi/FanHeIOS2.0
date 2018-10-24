//
//  ActivityOverViewCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/5/5.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ActivityOverViewCell.h"

@implementation ActivityOverViewCell
- (void)tranferActivityVIewCellModel:(MyActivityModel *)model{
    if (model.postid.integerValue  ==  0) {
        self.typeImageView.hidden = YES;
    }
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KWidthImageDefault];
    self.titleLabel.text = model.name;
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
