//
//  ChangeInformationMsgCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/7/20.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangeInformationMsgCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headviewImage;
@property (weak, nonatomic) IBOutlet UIImageView *veryImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *changeMsgLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
- (void)tranferChangeNotificationCellModel:(DynamicDetailModel *)model;
@end
