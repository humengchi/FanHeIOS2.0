//
//  ActivityGuestsCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/5.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ActivityGuestsCell.h"

@implementation ActivityGuestsCell
- (void)tranferActivityGuestsCellModel:(UserModel *)model{
    if (self.array.count == 1 || self.array.count == self.index+1) {
        self.lineView.hidden = YES;
    }
    self.heardImageView.layer.masksToBounds = YES;
    self.heardImageView.layer.cornerRadius = self.heardImageView.frame.size.width/2.0;
    [self.heardImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage: [UIImage imageNamed:@"icon_jb_mr"]];
    self.nameLabel.text = model.name;
    self.sideLabel.text = [CommonMethod paramStringIsNull:model.company];
}
+(CGFloat)backActivityGuestsCellHeigth:(UserModel *)model{
    NSString *str = [CommonMethod paramStringIsNull:model.company];

    CGFloat heigth = [NSHelper heightOfString:str font:[UIFont systemFontOfSize:14] width:WIDTH - 69 - 16];
    return heigth + 12 + 37;
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
