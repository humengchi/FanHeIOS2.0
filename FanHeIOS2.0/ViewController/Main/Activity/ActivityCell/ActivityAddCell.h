//
//  ActivityAddCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/3.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityAddCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *activityAddLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *costLabel;
@property (weak, nonatomic) IBOutlet UIImageView *nextImageView;
@property (weak, nonatomic) IBOutlet UIImageView *coveImageView;
@property (weak, nonatomic) IBOutlet UILabel *compayLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *vetryImageView;
@property (weak, nonatomic) IBOutlet UIImageView *phoneImageView;
@property (nonatomic,strong) MyActivityModel *model;
@property (nonatomic,strong) UserModel *useModel;
- (void)tranferActivityAddCellModel:(MyActivityModel *)model useModel:(UserModel *)usemodel;
@end
