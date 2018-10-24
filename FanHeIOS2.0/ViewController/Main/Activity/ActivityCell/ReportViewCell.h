//
//  ReportViewCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/5/4.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *reviewcountLabel;
@property (weak, nonatomic) IBOutlet UILabel *readeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
- (void)tranferReportModel:(ReportModel *)model;
@end
