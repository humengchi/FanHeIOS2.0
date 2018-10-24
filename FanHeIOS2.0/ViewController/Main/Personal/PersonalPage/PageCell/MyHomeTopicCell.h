//
//  MyHomeTopicCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/22.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyHomeTopicCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *countTextView;

@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *attionLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewPointLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewtitleLabel;
@property (nonatomic, strong)   NSNumber *userID;
@property (nonatomic ,strong) MyTopicModel *topModel;
- (void)tranferMyHomeTopicCellMyTopicModel:(MyTopicModel *)model;
+ (CGFloat)backMyHomeTopicCellHeigthMyTopicModel:(MyTopicModel *)model;
@end
