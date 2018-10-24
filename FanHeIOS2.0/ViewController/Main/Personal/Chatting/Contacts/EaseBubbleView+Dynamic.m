//
//  EaseBubbleView+Dynamic.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/3/24.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "EaseBubbleView+Dynamic.h"
#import "VariousDetailController.h"

@implementation EaseBubbleView (Dynamic)
- (void)_setupDayBunamicbbleMarginConstraints:(id<IMessageModel>)model
{
    if (model.isSender) {
        NSLayoutConstraint *marginTopConstraint = [NSLayoutConstraint constraintWithItem:self.backgroundImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.margin.top - 11];
        NSLayoutConstraint *marginBottomConstraint = [NSLayoutConstraint constraintWithItem:self.backgroundImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-self.margin.bottom ];
        NSLayoutConstraint *marginLeftConstraint = [NSLayoutConstraint constraintWithItem:self.backgroundImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-self.margin.right + 20];
        NSLayoutConstraint *marginRightConstraint = [NSLayoutConstraint constraintWithItem:self.backgroundImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.margin.left ];
        [self.marginConstraints removeAllObjects];
        [self.marginConstraints addObject:marginTopConstraint];
        [self.marginConstraints addObject:marginBottomConstraint];
        [self.marginConstraints addObject:marginLeftConstraint];
        [self.marginConstraints addObject:marginRightConstraint];
        
        [self addConstraints:self.marginConstraints];
        
    } else {
        NSLayoutConstraint * marginTopConstraint = [NSLayoutConstraint constraintWithItem:self.backgroundImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.margin.top - 10];
        NSLayoutConstraint * marginBottomConstraint = [NSLayoutConstraint constraintWithItem:self.backgroundImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-self.margin.bottom + 10];
        NSLayoutConstraint * marginLeftConstraint = [NSLayoutConstraint constraintWithItem:self.backgroundImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:self.margin.right - 20];
        NSLayoutConstraint * marginRightConstraint = [NSLayoutConstraint constraintWithItem:self.backgroundImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-self.margin.left + 10];
        [self.marginConstraints removeAllObjects];
        [self.marginConstraints addObject:marginTopConstraint];
        [self.marginConstraints addObject:marginBottomConstraint];
        [self.marginConstraints addObject:marginLeftConstraint];
        [self.marginConstraints addObject:marginRightConstraint];
        
        [self addConstraints:self.marginConstraints];
        
    }
    
    
    
}

- (void)_setupImageBubbleConstraints:(id<IMessageModel>)model
{
    [self _setupDayBunamicbbleMarginConstraints:model];
}

#pragma mark - public

- (void)setupDynamicBubbleView:(id<IMessageModel>)model
{
    self.backgroundImageView = [[UIImageView alloc] init];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 224, 80)];
    
    [self.backgroundImageView addSubview:imageView];
    self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.headerImageView = [UIImageView drawImageViewLine:CGRectMake(14, self.titleLabel.frame.origin.y + 18 + 25, 29, 29) bgColor:[UIColor clearColor]];
    self.headerImageView.layer.masksToBounds = YES; //没这句话它圆不起来
    self.headerImageView.layer.cornerRadius = 14.5; //设置图片圆角的尺度
    [imageView addSubview:self.headerImageView];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 12, 210, 12)];
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.backgroundImageView addSubview:self.titleLabel];
    
    self.countLabel =  [[UILabel alloc] initWithFrame:CGRectMake(46, 38, 170, 40)];
    self.countLabel.numberOfLines = 2;
    self.countLabel.font = [UIFont systemFontOfSize:12];
    [imageView addSubview:self.countLabel];
    
    self.lineView = [[UIView alloc]initWithFrame:CGRectMake(16, 36,192, 0.5)];
    
    [imageView addSubview:self.lineView];
    
    self.countLabel.textColor = [UIColor colorWithHexString:@"818C9E"];
    self.lineView.backgroundColor = [UIColor colorWithHexString:@"D9D9D9"];
    self.titleLabel.textColor = [UIColor colorWithHexString:@"41464E"];
    
    if (model.isSender) {
        UIImage *bgImage = bgImage = [[UIImage imageNamed:@"bg_card_tj2"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
        imageView.image = bgImage;
    }else{
        UIImage *bgImage = [[UIImage imageNamed:@"bg_card_tj1"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
        imageView.image = bgImage;
    }
    
    [self addSubview:self.backgroundImageView];
    self.backgroundImageView.image = [UIImage imageNamed:@""];
    self.imageView.image = [UIImage imageNamed:@""];
    self.backgroundImageView.backgroundColor = [UIColor clearColor];
    //   self.backgroundImageView.hidden = YES;
    [self _setupDayBunamicbbleMarginConstraints:model];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:228]];
    
}

- (void)updateDayMargin:(UIEdgeInsets)margin model:(id<IMessageModel>)model;
{
    if (_margin.top == margin.top && _margin.bottom == margin.bottom && _margin.left == margin.left && _margin.right == margin.right) {
        return;
    }
    _margin = margin;
    
    [self removeConstraints:self.marginConstraints];
    [self _setupDayBunamicbbleMarginConstraints:model];
}



@end
