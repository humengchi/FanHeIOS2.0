//
//  DynamicDetailCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/3/1.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DynamicDetailCellDelegate <NSObject>

- (void)likePraiseBtnAction:(NSInteger)index;
- (void)delectOrRateTapAction:(NSInteger )index;
- (void)longPreaaTapAction:(NSInteger )index;

@end
@interface DynamicDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *approveImageView;
@property (weak, nonatomic) IBOutlet UILabel *printecountLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (weak, nonatomic) IBOutlet UILabel *realeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *interviewImageView;
@property (weak, nonatomic) IBOutlet UILabel *backLabel;
@property (weak, nonatomic) IBOutlet UILabel *segLabel;
@property (weak, nonatomic) IBOutlet UIImageView *verImageView1;

@property (nonatomic ,assign) NSInteger indePathRow;

@property (nonatomic ,strong) FinanaceDetailModel *model;
@property (nonatomic, weak)id<DynamicDetailCellDelegate>dynamicDetailCellDelegate;
- (void)tranferFianaceDetailModel:(FinanaceDetailModel *)model;
+ (CGFloat)backHotRateViewCell:(FinanaceDetailModel *)model;
@end
