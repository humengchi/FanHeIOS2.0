//
//  ActivityAskCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/6.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityAskCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *askLabel;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UILabel *anverLabel;
@property (weak, nonatomic) IBOutlet UILabel *anverAwLabel;
@property (nonatomic, strong) UserModel *useModel;
- (void)tranferActivityAskCellModel:(UserModel *)model;
+ (CGFloat)backActivityAskCellHeigth:(UserModel *)model;
@end
