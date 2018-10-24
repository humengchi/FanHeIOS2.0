//
//  ReportPushTitleCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/5/4.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportPushTitleCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UILabel *pushTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *moreLabel;
@property (weak, nonatomic) IBOutlet UIImageView *nextImageView;
@property (nonatomic ,assign) BOOL isShow;
- (void)tranferNsinter;
@end
