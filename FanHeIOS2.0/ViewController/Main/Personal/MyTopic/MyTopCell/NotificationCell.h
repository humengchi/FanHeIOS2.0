//
//  NotificationCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/21.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NotificationCellDelegate <NSObject>

- (void)textViewTouchPointProcessing:(UITapGestureRecognizer *)tap;

@end

@interface NotificationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *ryhDelectLabel;

@property (weak, nonatomic) IBOutlet UITextView *titleTextView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *userTypeImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *atmessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *typeImage;
@property (weak, nonatomic) IBOutlet UILabel *attionlabel;
@property (weak, nonatomic) IBOutlet UILabel *viewpointLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIView *typeView;
@property (nonatomic ,strong) MyTopicModel *model;
@property (nonatomic ,weak)id<NotificationCellDelegate>notificationCellDelegate;
- (void)createrNotificationCellNotificationCell:(MyTopicModel *)model;
+ (CGFloat)backNotificationCellMyTopicModel:(MyTopicModel *)model;
@end
