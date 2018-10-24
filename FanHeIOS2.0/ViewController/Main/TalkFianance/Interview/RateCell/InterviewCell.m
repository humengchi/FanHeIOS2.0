//
//  InterviewCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/19.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "InterviewCell.h"

@implementation InterviewCell
+ (CGFloat)tableFrameInterviewCellHeigthContactsModel:(FinanaceModel *)fianaceModel{
    CGFloat heigth = 167.0/343.0*(WIDTH - 32) + 76;
    NSString *strTitle = fianaceModel.title;
    
    CGFloat heigth1 = [NSHelper heightOfString:strTitle font:[UIFont systemFontOfSize:14] width:WIDTH - 32];
    if (heigth1 > 18) {
        heigth1 = 32;
        return heigth1 + heigth;
    }else{
        heigth1 = 14;
    }
    return heigth + heigth1;
}
- (void)tranferInterviewCellFianaceModel:(TalkFianaceModel *)fianaceModel{
    [self.CoverImageVIew sd_setImageWithURL:[NSURL URLWithString:fianaceModel.image] placeholderImage:KWidthImageDefault];
    self.TitleLabel.text = fianaceModel.title;
    self.RateCountLabel.text = [NSString stringWithFormat:@"评论 %ld",fianaceModel.reviewcount.integerValue];
    self.ReadCountLabel.text = [NSString stringWithFormat:@"阅读 %ld",fianaceModel.readcount.integerValue];
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
