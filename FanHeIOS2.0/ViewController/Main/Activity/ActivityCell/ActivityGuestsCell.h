//
//  ActivityGuestsCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/5.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityGuestsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UIImageView *heardImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sideLabel;
@property (nonatomic ,strong) NSMutableArray *array;
@property (nonatomic ,assign) NSInteger index;
- (void)tranferActivityGuestsCellModel:(UserModel *)model;
+(CGFloat)backActivityGuestsCellHeigth:(UserModel *)model;
@end
