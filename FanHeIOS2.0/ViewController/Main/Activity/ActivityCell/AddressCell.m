//
//  AddressCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/5.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "AddressCell.h"

@implementation AddressCell
- (void)tranferAddressCellModel:(MyActivityModel *)model{
    NSString *str = [NSString stringWithFormat:@"%@%@%@",model.cityname,model.districtname,model.address];
    CGFloat heigth = [NSHelper heightOfString:str font:[UIFont systemFontOfSize:14] width:WIDTH - 65];
    heigth = 32 + heigth;
    self.addressImageView.frame = CGRectMake(16, heigth/2 - 6 , 11, 12);
    self.leftImageView.frame = CGRectMake(WIDTH - 24, heigth/2 - 7, 8, 14);
    self.addressLabel.frame = CGRectMake(35, 16, WIDTH - 65,heigth -32);
    self.addressLabel.text = str;
}
+ (CGFloat)backAddressCellHeigth:(MyActivityModel *)model{
    NSString *addstr = [NSString stringWithFormat:@"%@%@%@",model.cityname,model.districtname,model.address];
   CGFloat heigth = [NSHelper heightOfString:addstr font:[UIFont systemFontOfSize:14] width:WIDTH - 65];
    return heigth + 32;
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
