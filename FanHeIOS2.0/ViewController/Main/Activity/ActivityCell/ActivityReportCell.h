//
//  ActivityReportCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityReportCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
- (void)tranferActivityReportCellModel:(FinanaceDetailModel *)model;
+ (CGFloat)backActivityReportCellHeigth:(FinanaceDetailModel *)model;
@end
