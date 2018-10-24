//
//  TickerCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/10.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "TickerCell.h"

@implementation TickerCell
- (void)tranferTickerCellModel:(TicketModel *)model{
    self.nameLabel.text = model.name;
    if (model.price.integerValue == 0) {
        self.priceLabel.text = @"免费";
    }else{
        self.priceLabel.text = [NSString stringWithFormat:@"¥%@元/人",model.price];
    }
    if (model.remainnum.integerValue == -1) {
        self.countLabel.text = @"名额不限";
    }else{
        self.countLabel.text = [NSString stringWithFormat:@"剩余:%@",model.remainnum];
    }
    if (model.remainnum.integerValue == 0){
        self.nameLabel.textColor = [UIColor colorWithHexString:@"E6E8EB"];
         self.countLabel.textColor = [UIColor colorWithHexString:@"E6E8EB"];
         self.priceLabel.textColor = [UIColor colorWithHexString:@"E6E8EB"];
    }else{
        self.nameLabel.textColor = [UIColor colorWithHexString:@"41464E"];
        self.countLabel.textColor = [UIColor colorWithHexString:@"1ABC9C"];
        self.priceLabel.textColor = [UIColor colorWithHexString:@"818C9E"];
    }
    if (self.index == self.array.count - 1) {
        self.lineView.hidden = YES;
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
