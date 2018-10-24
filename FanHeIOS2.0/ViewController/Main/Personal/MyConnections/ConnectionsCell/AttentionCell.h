//
//  AttentionCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/29.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AttentionCellDelegate <NSObject>

- (void)exchangeAttionAction:(NSInteger)index;

@end

@interface AttentionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *vipImageView;
@property (weak, nonatomic) IBOutlet UIButton *exchangeBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *postionLabel;
@property (nonatomic ,assign) NSInteger index;
@property (weak, nonatomic) IBOutlet UILabel *realName;

@property (nonatomic ,weak) id<AttentionCellDelegate>atteneionDelegate;
- (void)exchangeCardBtn:(ChartModel *)model type:(NSInteger)index;
@end
