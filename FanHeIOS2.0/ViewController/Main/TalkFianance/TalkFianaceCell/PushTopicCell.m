//
//  PushTopicCell.m
//  FanHeIOS2.0
//
//  Created by JackieWang on 15/12/2016.
//  Copyright © 2016 胡梦驰. All rights reserved.
//

#import "PushTopicCell.h"

@implementation PushTopicCell
- (void)tranferPushTopicModel:(FinanaceModel *)model{
    
    [self.coverImangeView sd_setImageWithURL:[NSURL URLWithString:model.photo] placeholderImage:KWidthImageDefault];
    self.titleLabel.text = model.title;
    CGFloat heigth = [NSHelper heightOfString:model.title font:[UIFont systemFontOfSize:17] width:WIDTH - 52];
      CGFloat heigth1 = 167.0/343.0*(WIDTH - 32) + 68;
    if (heigth > 25) {
        heigth = 34;
    }else{
        heigth = 17;
    }
   self.backImage.frame = CGRectMake(16, heigth1 - 23 - heigth - 40 - 6, WIDTH - 32, heigth + 23);
    self.rateCountLabel.text = [NSString stringWithFormat:@"评论 %@",[NSString getNumStr:model.reviewcount]];
    self.attionCountlabel.text = [NSString stringWithFormat:@"关注 %@",[NSString getNumStr:model.attentcount]];
    self.viewpointLabel.text = [NSString stringWithFormat:@"观点 %@",[NSString getNumStr:model.replycount]];
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
