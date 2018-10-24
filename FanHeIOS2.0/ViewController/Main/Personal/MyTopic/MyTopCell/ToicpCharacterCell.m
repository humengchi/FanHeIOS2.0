
//
//  ToicpCharacterCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/20.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ToicpCharacterCell.h"

@implementation ToicpCharacterCell
- (void)tranferToicpCharacterCellMyTopicModel:(MyTopicModel *)model{
    self.attionLabel.text = [NSString stringWithFormat:@"关注 %@",model.attentcount];
    self.viewPointLabel.text = [NSString stringWithFormat:@"观点 %@",model.replycount];
    self.rateLabel.text = [NSString stringWithFormat:@"评论 %@",model.reviewcount];
    CGFloat heigth = [NSHelper heightOfString:model.title font:[UIFont systemFontOfSize:14] width:WIDTH - 61 - 16];
    if (heigth > 18) {
        self.titleLabel.frame = CGRectMake(61, 16, WIDTH - 61 - 16, 36);
    }else{
        self.titleLabel.frame = CGRectMake(61, 28, WIDTH - 61 - 16, 14);
    }
    self.titleLabel.text = model.title;

}
+ (CGFloat)backToicpCharacterCell:(MyTopicModel *)model{
    CGFloat heigth = [NSHelper heightOfString:model.title font:[UIFont systemFontOfSize:14] width:WIDTH - 61 - 16];
    if (heigth > 18) {
        heigth = 28;
    }else{
        heigth = 14;
    }

    return heigth + 54;
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
