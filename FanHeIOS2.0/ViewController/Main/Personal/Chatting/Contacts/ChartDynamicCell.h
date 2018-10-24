//
//  ChartDynamicCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/3/7.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "EaseBaseMessageCell.h"

@interface ChartDynamicCell : EaseBaseMessageCell


//
//@property (nonatomic,strong) UILabel *timeLabel;
//@property (nonatomic,strong) UILabel *addressLabel;
//
//
//
//
//@property (nonatomic,strong) UIImageView  *headerImageView;
//@property (nonatomic,strong) UIImageView  *bgImage;
//@property (nonatomic,strong) UILabel *titleLabel;
//@property (nonatomic,strong) UILabel *countLabel;
//@property (nonatomic,assign) CGFloat wideth;
//@property (nonatomic,strong) UIView *lineView;
@property (nonatomic) NSLayoutConstraint *avatarWidthConstraint;
@property (nonatomic) NSLayoutConstraint *bubbleWithImageConstraint;
@property (nonatomic) NSLayoutConstraint *nameHeightConstraint;
@end
