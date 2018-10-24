//
//  ActivityReportListCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/5/5.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityReportListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewcountLabel;
- (void)tranferActivityReportModel:(ReportModel *)model;
@property (weak, nonatomic) IBOutlet UILabel *readcountLabel;
@end
