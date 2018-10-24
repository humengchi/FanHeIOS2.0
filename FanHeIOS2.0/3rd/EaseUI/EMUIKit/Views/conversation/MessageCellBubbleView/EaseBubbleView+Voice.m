//
//  EaseBubbleView+Voice.m
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/7/2.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "EaseBubbleView+Voice.h"

#define ISREAD_VIEW_SIZE 10.f

@implementation EaseBubbleView (Voice)

#pragma mark - private

- (void)_setupVoiceBubbleMarginConstraints
{
    [self.marginConstraints removeAllObjects];
    
    //image view
    NSLayoutConstraint *imageWithMarginTopConstraint = [NSLayoutConstraint constraintWithItem:self.voiceImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeTop multiplier:1.0 constant:12];
    NSLayoutConstraint *imageWithMarginBottomConstraint = [NSLayoutConstraint constraintWithItem:self.voiceImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-12];
    [self.marginConstraints addObject:imageWithMarginTopConstraint];
    [self.marginConstraints addObject:imageWithMarginBottomConstraint];

    //duration label
    NSLayoutConstraint *durationWithMarginTopConstraint = [NSLayoutConstraint constraintWithItem:self.voiceDurationLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.margin.bottom];
    NSLayoutConstraint *durationWithMarginBottomConstraint = [NSLayoutConstraint constraintWithItem:self.voiceDurationLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:self.margin.bottom];
    [self.marginConstraints addObject:durationWithMarginTopConstraint];
    [self.marginConstraints addObject:durationWithMarginBottomConstraint];
    //text
    //duration label
    NSLayoutConstraint *durationWithMarginTopConstraintText = [NSLayoutConstraint constraintWithItem:self.voiceLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.margin.bottom];
    NSLayoutConstraint *durationWithMarginBottomConstraintText = [NSLayoutConstraint constraintWithItem:self.voiceLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:self.margin.bottom];
    [self.marginConstraints addObject:durationWithMarginTopConstraintText];
    [self.marginConstraints addObject:durationWithMarginBottomConstraintText];

    if(self.isSender){
        NSLayoutConstraint *imageWithMarginRightConstraint = [NSLayoutConstraint constraintWithItem:self.voiceImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-self.margin.right];
        [self.marginConstraints addObject:imageWithMarginRightConstraint];
        NSLayoutConstraint *durationRightConstraint = [NSLayoutConstraint constraintWithItem:self.voiceDurationLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.voiceImageView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-EaseMessageCellPadding];
        [self.marginConstraints addObject:durationRightConstraint];
        
        NSLayoutConstraint *durationLeftConstraint = [NSLayoutConstraint constraintWithItem:self.voiceDurationLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.margin.left];
        [self.marginConstraints addObject:durationLeftConstraint];

        //text

        NSLayoutConstraint *durationRightConstraintText = [NSLayoutConstraint constraintWithItem:self.voiceLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.margin.left- 14];
        [self.marginConstraints addObject:durationRightConstraintText];
        
        NSLayoutConstraint *durationLeftConstraintText = [NSLayoutConstraint constraintWithItem:self.voiceLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-self.margin.left-20];
        [self.marginConstraints addObject:durationLeftConstraintText];
    }
    else{
        NSLayoutConstraint *imageWithMarginLeftConstraint = [NSLayoutConstraint constraintWithItem:self.voiceImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.margin.right];
        [self.marginConstraints addObject:imageWithMarginLeftConstraint];
        NSLayoutConstraint *durationLeftConstraint = [NSLayoutConstraint constraintWithItem:self.voiceDurationLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.voiceImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:EaseMessageCellPadding];
        [self.marginConstraints addObject:durationLeftConstraint];
        
        NSLayoutConstraint *durationRightConstraint = [NSLayoutConstraint constraintWithItem:self.voiceDurationLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-self.margin.right];
        [self.marginConstraints addObject:durationRightConstraint];
          //text
        NSLayoutConstraint *durationLeftConstrainttext = [NSLayoutConstraint constraintWithItem:self.voiceLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-self.margin.right+14];
        [self.marginConstraints addObject:durationLeftConstrainttext];
        
        NSLayoutConstraint *durationRightConstrainttext = [NSLayoutConstraint constraintWithItem:self.voiceDurationLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:self.margin.left+20];
        [self.marginConstraints addObject:durationRightConstrainttext];
//        isReadView
        [self.marginConstraints addObject:[NSLayoutConstraint constraintWithItem:self.isReadView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:ISREAD_VIEW_SIZE/2 + 16]];
        [self.marginConstraints addObject:[NSLayoutConstraint constraintWithItem:self.isReadView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-(ISREAD_VIEW_SIZE/2-16)]];
        [self.marginConstraints addObject:[NSLayoutConstraint constraintWithItem:self.isReadView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
        [self.marginConstraints addObject:[NSLayoutConstraint constraintWithItem:self.isReadView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeTop multiplier:1.0 constant:ISREAD_VIEW_SIZE]];
    }
    
    [self addConstraints:self.marginConstraints];
}

- (void)_setupVoiceBubbleConstraints
{
    if (self.isSender) {
        self.isReadView.hidden = YES;
    }
    [self _setupVoiceBubbleMarginConstraints];
}

#pragma mark - public

- (void)setupVoiceBubbleView
{
    self.voiceImageView = [[UIImageView alloc] init];
    self.voiceImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.voiceImageView.backgroundColor = [UIColor clearColor];
    self.voiceImageView.animationDuration = 1;
    [self.backgroundImageView addSubview:self.voiceImageView];
    
    self.voiceDurationLabel = [[UILabel alloc] init];
    self.voiceDurationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.voiceDurationLabel.backgroundColor = [UIColor clearColor];
    [self.backgroundImageView addSubview:self.voiceDurationLabel];
    self.isReadView = [[UIImageView alloc] init];
    self.isReadView.translatesAutoresizingMaskIntoConstraints = NO;
    self.isReadView.layer.cornerRadius = 10/2;
    self.isReadView.clipsToBounds = YES;
    self.isReadView.backgroundColor = [UIColor redColor];
    [self addSubview:self.isReadView];
     self.voiceLabel = [[UILabel alloc]init];
    self.voiceLabel.font = [UIFont systemFontOfSize:12];
       self.voiceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.voiceLabel.textColor = [UIColor grayColor];
      [self addSubview:self.voiceLabel];
    self.voiceDurationLabel.hidden = YES;
    [self _setupVoiceBubbleConstraints];
}

- (void)updateVoiceMargin:(UIEdgeInsets)margin
{
    if (_margin.top == margin.top && _margin.bottom == margin.bottom && _margin.left == margin.left && _margin.right == margin.right) {
        return;
    }
    _margin = margin;
    
    [self removeConstraints:self.marginConstraints];
    [self _setupVoiceBubbleMarginConstraints];
}

@end
