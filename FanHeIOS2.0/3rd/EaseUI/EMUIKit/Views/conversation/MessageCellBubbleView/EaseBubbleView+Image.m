//
//  EaseBubbleView+Image.m
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/7/2.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "EaseBubbleView+Image.h"

@implementation EaseBubbleView (Image)

#pragma mark - private

- (void)_setupImageBubbleMarginConstraints_image
{
   
//    NSLayoutConstraint *marginTopConstraint = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-2];
//    NSLayoutConstraint *marginBottomConstraint = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-2];
//    NSLayoutConstraint *marginLeftConstraint;
//    NSLayoutConstraint *marginRightConstraint;
//    if (self.isSender) {
//        marginLeftConstraint  = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-8];
//        marginRightConstraint = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:2];
//    }else{
//        marginLeftConstraint  = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-4];
//        marginRightConstraint = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:8];
//    }
//
//    
//    [self.marginConstraints removeAllObjects];
//    [self.marginConstraints addObject:marginTopConstraint];
//    [self.marginConstraints addObject:marginBottomConstraint];
//    [self.marginConstraints addObject:marginLeftConstraint];
//    [self.marginConstraints addObject:marginRightConstraint];
//    
//    [self addConstraints:self.marginConstraints];
    NSLayoutConstraint *marginTopConstraint = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:-3];
    NSLayoutConstraint *marginBottomConstraint = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-2];
    NSLayoutConstraint *marginLeftConstraint;
    NSLayoutConstraint *marginRightConstraint;
    if (self.isSender) {
        marginLeftConstraint  = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-5];
        marginRightConstraint = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:2];
    }else{
        marginLeftConstraint  = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-2];
        marginRightConstraint = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:5];
    }
    
    [self.marginConstraints removeAllObjects];
    [self.marginConstraints addObject:marginTopConstraint];
    [self.marginConstraints addObject:marginBottomConstraint];
    [self.marginConstraints addObject:marginLeftConstraint];
    [self.marginConstraints addObject:marginRightConstraint];
    
    [self addConstraints:self.marginConstraints];
}

- (void)_setupImageBubbleConstraints_image
{
      [self _setupImageBubbleMarginConstraints_image];
}

#pragma mark - public

- (void)setupImageBubbleView
{
    self.imageView = [[UIImageView alloc] init];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageView.backgroundColor = [UIColor clearColor];
    [self.backgroundImageView addSubview:self.imageView];
   
    
    [self _setupImageBubbleConstraints_image];
}

- (void)updateImageMargin:(UIEdgeInsets)margin
{
    if (_margin.top == margin.top && _margin.bottom == margin.bottom && _margin.left == margin.left && _margin.right == margin.right) {
        return;
    }
    _margin = margin;
    
    [self removeConstraints:self.marginConstraints];
    [self _setupImageBubbleMarginConstraints_image];
}

@end
