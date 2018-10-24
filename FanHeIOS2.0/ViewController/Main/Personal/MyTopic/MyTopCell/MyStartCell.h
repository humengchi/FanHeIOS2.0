//
//  MyStartCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/20.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyStartCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLAbel;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *attionLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewPointLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewtitleLabel;
@property (nonatomic ,strong) MyTopicModel *topModel;
- (void)tranferMyStartCellMyTopicModel:(MyTopicModel *)model;
+ (CGFloat)backMyStartCellHeigthMyTopicModel:(MyTopicModel *)model;
@end
