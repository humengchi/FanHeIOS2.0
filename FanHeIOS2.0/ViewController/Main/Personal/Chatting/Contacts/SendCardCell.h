//
//  SendCardCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/25.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "EaseBaseMessageCell.h"


@interface SendCardCell : EaseBaseMessageCell
@property (nonatomic,strong) UIImageView  *headerImageView;
@property (nonatomic,strong) UIImageView  *bgImage;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *postionLabel;
@property (nonatomic,strong) UILabel *locationLabel;
@property (nonatomic,strong) UILabel *goodAtLabel;
@property (nonatomic,assign) CGFloat wideth;
@property (nonatomic,strong) UIView *lineView;
@property (nonatomic) NSLayoutConstraint *avatarWidthConstraint;
@property (nonatomic) NSLayoutConstraint *bubbleWithImageConstraint;
@property (nonatomic) NSLayoutConstraint *nameHeightConstraint;
@end
