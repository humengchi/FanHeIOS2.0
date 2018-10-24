//
//  SupplyAndNeedMyCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/9/4.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "EaseBaseMessageCell.h"

@interface SupplyAndNeedMyCell : EaseBaseMessageCell
@property (nonatomic,strong) UIImageView  *headerImageView;
@property (nonatomic,strong) UIImageView  *bgImage;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *postionLabel;
@property (nonatomic,strong) UIView *lineView;
@property (nonatomic) NSLayoutConstraint *avatarWidthConstraint;
@property (nonatomic) NSLayoutConstraint *bubbleWithImageConstraint;
@property (nonatomic) NSLayoutConstraint *nameHeightConstraint;
@end
