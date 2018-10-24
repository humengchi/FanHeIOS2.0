//
//  ActivityVIewCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/29.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityVIewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *guestnameLabel;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UIImageView *addBackImageView;
@property (nonatomic,assign)NSInteger index;
- (void)tranferActivityVIewCellModel:(MyActivityModel *)model;

@end
