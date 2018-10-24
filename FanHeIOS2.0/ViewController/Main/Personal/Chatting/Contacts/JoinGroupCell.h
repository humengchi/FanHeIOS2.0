//
//  JoinGroupCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/9/4.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "EaseBaseMessageCell.h"

@interface JoinGroupCell : EaseBaseMessageCell

@property (nonatomic,strong) UIImageView  *bgImage;
@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic) NSLayoutConstraint *avatarWidthConstraint;
@property (nonatomic) NSLayoutConstraint *bubbleWithImageConstraint;
@property (nonatomic) NSLayoutConstraint *nameHeightConstraint;
@end
