//
//  MyActivityCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/4.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyActivityCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
- (void)tranferMyActivityCellModel:(MyActivityModel *)model;
+ (CGFloat)backMyActivityCellHeigth:(MyActivityModel *)model;
@end
