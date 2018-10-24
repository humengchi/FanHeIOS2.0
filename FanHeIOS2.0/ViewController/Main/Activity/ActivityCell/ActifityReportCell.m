//
//  ActifityReportCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/3.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ActifityReportCell.h"

@implementation ActifityReportCell
- (void)tranferActifityReportCellModel:(MyActivityModel *)model{
    self.reportLabel.text = model.title;
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
