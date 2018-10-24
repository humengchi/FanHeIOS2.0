//
//  ActivityVIewCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/29.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ActivityVIewCell.h"

@implementation ActivityVIewCell
- (void)tranferActivityVIewCellModel:(MyActivityModel *)model{
    if (self.index == 0) {
      self.backView.backgroundColor = HEX_COLOR(@"E6E8EB");
    }
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:[UIImage imageNamed:@"Place"]];
    self.titleLabel.text = model.name;
    self.timeLabel.text = model.timestr;
    self.addressLabel.text = [NSString stringWithFormat:@"%@%@",model.cityname,model.districtname];
    self.startLabel.text = model.price;
    if (model.addresstype.integerValue != 1) {
        self.addBackImageView.hidden = YES;
    }
    if ([model.price isEqualToString:@"免费"]) {
        self.startLabel.textColor = [UIColor colorWithHexString:@"1ABC9C"];
    }else if ([model.price isEqualToString:@"已结束"]) {
        self.startLabel.textColor = [UIColor colorWithHexString:@"AFB6C1"];
    }else{
         self.startLabel.textColor = [UIColor colorWithHexString:@"F76B1C"];
    }
    CGFloat addWideth = [NSHelper widthOfString:self.addressLabel.text font:[UIFont systemFontOfSize:14] height:14];
    CGFloat wideth = self.addressLabel.frame.origin.x + addWideth;
    CGFloat heigth = [NSHelper heightOfString:model.name font:[UIFont systemFontOfSize:17] width:WIDTH - 32];
    if (heigth > 25) {
        heigth =  42;
    }

    CGFloat wideth1 = [NSHelper widthOfString:model.guestname font:[UIFont systemFontOfSize:14] height:14];
    wideth1 += 16;
    if (wideth1 >  (WIDTH - wideth - self.startLabel.frame.size.width - 16 - 16)) {
        wideth1 = WIDTH - wideth - self.startLabel.frame.size.width - 16 - 16;
    }
    NSInteger guestanNameWideth = (CGFloat)wideth1;
//    self.guestnameLabel.frame =CGRectMake(wideth + 16, 254 + heigth, guestanNameWideth, 20);
    self.guestnameLabel.textColor = HEX_COLOR(@"B0A175");
    self.guestnameLabel.backgroundColor = HEX_COLOR(@"FAF5E0");
    self.guestnameLabel.layer.masksToBounds = YES;
    self.guestnameLabel.layer.cornerRadius = 5;
    self.guestnameLabel.font = [UIFont systemFontOfSize:14];
     if (model.guestname.length > 0) {
        self.guestnameLabel.text = [NSString stringWithFormat:@" %@ ",model.guestname];
    }else{
        self.guestnameLabel.hidden = YES;
    }
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
