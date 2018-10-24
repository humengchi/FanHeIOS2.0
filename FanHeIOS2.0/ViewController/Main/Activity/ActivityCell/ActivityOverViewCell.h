//
//  ActivityOverViewCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/5/5.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityOverViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *startImageView;
@property (weak, nonatomic) IBOutlet UIImageView *typeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
- (void)tranferActivityVIewCellModel:(MyActivityModel *)model;

@end
