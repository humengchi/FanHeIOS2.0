//
//  HotRateViewCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/17.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HotRateViewCellDelegate <NSObject>

- (void)likePraiseBtnAction:(NSInteger)index hotRate:(BOOL)start;
- (void)delectOrRateTapAction:(NSInteger )index hotRate:(BOOL)start;
- (void)longPreaaTapAction:(NSInteger )index hotRate:(BOOL)start;
- (void)attentionTapAction;


@end

@interface HotRateViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *memberImageView;
@property (weak, nonatomic) IBOutlet UIImageView *intVisiyionImageViwe;
@property (weak, nonatomic) IBOutlet UILabel *rateCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeRateBtn;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *headerAttentBtn;
@property (nonatomic, assign) BOOL dynicmaList;
@property (nonatomic, assign) BOOL secoundType;
@property (nonatomic, assign) NSInteger indePathRow;
@property (weak, nonatomic) IBOutlet UILabel *backName;
@property (nonatomic, weak)id<HotRateViewCellDelegate>hotRateViewCellDelegate;
@property (nonatomic ,strong) FinanaceDetailModel *model;
- (void)tranferFianaceDetailModel:(FinanaceDetailModel *)model;
+ (CGFloat)backHotRateViewCell:(FinanaceDetailModel *)model;
@end
