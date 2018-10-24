//
//  MyActivityCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/4.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "MyActivityCell.h"

@implementation MyActivityCell
- (void)tranferMyActivityCellModel:(MyActivityModel *)model{
    self.titleLabel.text = model.name;
    self.timeLabel.text = [NSString stringWithFormat:@"%@ 至 %@",model.starttime,model.endtime];
    self.addressLabel.text = [NSString stringWithFormat:@"%@ 至 %@",model.cityname,model.districtname];
    self.startLabel.text = model.price;
    self.startLabel.layer.borderWidth = 0.3;
    self.startLabel.layer.masksToBounds = YES;
    self.startLabel.layer.cornerRadius = 2;
    if ([model.price isEqualToString:@"已取消"]) {
        self.startLabel.layer.borderColor = [[UIColor colorWithHexString:@"AFB6C1"] CGColor];
        self.startLabel.textColor = [UIColor colorWithHexString:@"AFB6C1"];
    }else if ([model.price isEqualToString:@"已结束"]){
        self.startLabel.layer.borderColor = [[UIColor colorWithHexString:@"41464E"] CGColor];
        self.startLabel.textColor = [UIColor colorWithHexString:@"41464E"];
    }else if ([model.price isEqualToString:@"未通过"]){
        self.startLabel.layer.borderColor = [[UIColor colorWithHexString:@"E24943"] CGColor];
        self.startLabel.textColor = [UIColor colorWithHexString:@"E24943"];
    }else{
        self.startLabel.layer.borderColor = [[UIColor colorWithHexString:@"1ABC9C"] CGColor];
    }
}

+ (CGFloat)backMyActivityCellHeigth:(MyActivityModel *)model{
    CGFloat heigth = [NSHelper heightOfString:model.name font:[UIFont systemFontOfSize:14] width:WIDTH - 32];
    if (heigth > 20) {
        return 32;
    }
    return heigth + 83;
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
