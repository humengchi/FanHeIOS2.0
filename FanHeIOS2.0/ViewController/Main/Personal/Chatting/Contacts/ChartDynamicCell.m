//
//  ChartDynamicCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/3/7.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ChartDynamicCell.h"
#import "EaseBubbleView+Dynamic.h"



@implementation ChartDynamicCell
#pragma mark - IModelCell

- (BOOL)isCustomBubbleView:(id<IMessageModel>)model
{
    return YES;
}

- (void)setCustomModel:(id<IMessageModel>)model{    
    NSDictionary *ext = model.message.ext;
    if (ext[@"imageUrl"]) {
        [self.bubbleView.headerImageView sd_setImageWithURL:[NSURL URLWithString:ext[@"imageUrl"]] placeholderImage:KHeadImageDefaultName(ext[@"realname"])];
    } else {
        self.bubbleView.headerImageView.image = model.avatarImage;
    }
    if([CommonMethod paramStringIsNull:ext[@"title"]].length){
        self.bubbleView.titleLabel.text = ext[@"title"];
    }else{
        self.bubbleView.titleLabel.text = [NSString stringWithFormat:@"%@的金脉动态",ext[@"realname"]];
    }
    
    NSString *str = ext[@"count"];
    self.bubbleView.countLabel.text =  [str filterHTML];
    if (model.avatarURLPath) {
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:model.avatarURLPath] placeholderImage:model.avatarImage];
    } else {
        self.avatarView.image = model.avatarImage;
    }
}

- (void)setCustomBubbleView:(id<IMessageModel>)model
{
    [_bubbleView setupDynamicBubbleView:model];
}

- (void)updateCustomBubbleViewMargin:(UIEdgeInsets)bubbleMargin model:(id<IMessageModel>)model
{
    
    [_bubbleView updateDayMargin:bubbleMargin model:model];
    
}

/*!
 @method
 @brief 获取cell的重用标识
 @discussion
 @param model   消息model
 @return 返回cell的重用标识
 */
+ (NSString *)cellIdentifierWithModel:(id<IMessageModel>)model
{
    return @"ChartDynamicCell";
}

/*!
 @method
 @brief 获取cell的高度
 @discussion
 @param model   消息model
 @return  返回cell的高度
 */
+ (CGFloat)cellHeightWithModel:(id<IMessageModel>)model
{
    return 100;
}

@end
