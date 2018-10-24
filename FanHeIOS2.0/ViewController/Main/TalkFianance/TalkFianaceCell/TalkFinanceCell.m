//
//  TalkFinanceCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/15.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "TalkFinanceCell.h"

@implementation TalkFinanceCell
- (void)tranferFianaceModel:(FinanaceModel *)fianaceModel{
    [self.coverImageVIew sd_setImageWithURL:[NSURL URLWithString:fianaceModel.photo] placeholderImage:KWidthImageDefault];
    self.titleLabel.text = fianaceModel.title;
    self.rateCountLabel.text = [NSString stringWithFormat:@"评论 %ld",fianaceModel.reviewcount.integerValue];
    self.readCountLabel.text = [NSString stringWithFormat:@"阅读 %ld",fianaceModel.readcount.integerValue];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
+ (CGFloat)tableFrameTalkFinanceCellHeigthContactsModel:(FinanaceModel *)fianaceModel{
    CGFloat heigth = 167.0/343.0*(WIDTH - 32) + 72;
    NSString *strTitle = fianaceModel.title;

    CGFloat heigth1 = [NSHelper heightOfString:strTitle font:[UIFont systemFontOfSize:17] width:WIDTH - 32];
    if (heigth1 > 18) {
        heigth1 = 32;
        return heigth1 + heigth;
    }else{
        heigth1 = 17;
    }
    return heigth + heigth1;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
