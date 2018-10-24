//
//  ReportPushTitleCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/5/4.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ReportPushTitleCell.h"
#import "ActivityReportListController.h"
@implementation ReportPushTitleCell
- (void)tranferNsinter{
    if (self.isShow) {
        self.pushTitleLabel.text = @"活动推荐";
        self.moreLabel.hidden = YES;
        self.nextImageView.hidden = YES;
        self.coverView.userInteractionEnabled = NO;
    }else{
        self.pushTitleLabel.text = @"活动报道";
         self.coverView.userInteractionEnabled = YES;
    }

}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)gotoMoreReport:(UITapGestureRecognizer *)sender {
    ActivityReportListController *reportCtr = [[ActivityReportListController alloc]init];
    [[self viewController].navigationController pushViewController:reportCtr animated:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
