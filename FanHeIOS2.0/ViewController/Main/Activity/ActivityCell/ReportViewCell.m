//
//  ReportViewCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/5/4.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ReportViewCell.h"

@implementation ReportViewCell
- (void)tranferReportModel:(ReportModel *)model{
    self.coverImage.clipsToBounds = YES;
    self.coverImage.contentMode = UIViewContentModeScaleAspectFill;
    [self.coverImage sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KWidthImageDefault];
    
    self.titleLabel.text = model.title;
    self.readeLabel.text = [NSString stringWithFormat:@"阅读数%@",model.readcount];
     self.reviewcountLabel.text = [NSString stringWithFormat:@"评论数%@",model.reviewcount];
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
