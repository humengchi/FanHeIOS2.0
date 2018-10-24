//
//  ReportTitleLabel.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/5/4.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportTitleLabel : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
- (void)tranferReportModel:(ReportModel *)model;
@end
