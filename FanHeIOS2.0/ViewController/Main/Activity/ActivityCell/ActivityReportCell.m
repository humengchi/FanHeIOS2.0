//
//  ActivityReportCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ActivityReportCell.h"

@implementation ActivityReportCell
- (void)tranferActivityReportCellModel:(FinanaceDetailModel *)model{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:model.title];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paragraphStyle setLineSpacing:12];//调整行间距
    
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [model.title length])];
    self.titleLabel.attributedText = attributedString;
}
+ (CGFloat)backActivityReportCellHeigth:(FinanaceDetailModel *)model{
    
    CGSize size = CGSizeMake(WIDTH - 32, 0);
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    [style setLineSpacing:12];
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:24],NSParagraphStyleAttributeName:style};
    CGSize retSize = [model.title boundingRectWithSize:size
                                                options:\
                      NSStringDrawingTruncatesLastVisibleLine |
                      NSStringDrawingUsesLineFragmentOrigin |
                      NSStringDrawingUsesFontLeading
                                             attributes:attribute
                                                context:nil].size;
    
    
    CGFloat heigth = retSize.height+ 40;
    return heigth;
    
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
