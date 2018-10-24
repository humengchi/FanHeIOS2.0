//
//  WorkHistoryDetailCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/2/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WorkHistoryDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *registImageView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *verfyIamgeView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *workYearLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
- (void)tranfrtWorkHistoryDetailCellModel:(UserModel *)model;

@end
