//
//  FianaceCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/15.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "FianaceCell.h"

@implementation FianaceCell
- (IBAction)sendBtnAction:(UIButton *)sender {
    if ([self.fianaceCellDelegate respondsToSelector:@selector(gotoIntviewProgramme)]) {
        [self.fianaceCellDelegate gotoIntviewProgramme];
    }
}
- (void)tranferFianaceCell{
    [self.sendActionBtn.layer setMasksToBounds:YES];
    [self.sendActionBtn.layer setCornerRadius:12.0]; //设置矩形四个圆角半径
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
