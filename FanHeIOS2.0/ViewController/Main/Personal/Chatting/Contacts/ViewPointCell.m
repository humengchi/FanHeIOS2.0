//
//  ViewPointCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/3/28.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ViewPointCell.h"
#import "EaseBubbleView+ViewPoint.h"
@implementation ViewPointCell


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
    self.bubbleView.titleLabel.text = [NSString stringWithFormat:@"%@的观点",ext[@"realname"]];
    NSString *str = @"发布了一个观点";
    self.bubbleView.countLabel.text =  [str filterHTML];
    if (model.avatarURLPath) {
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:model.avatarURLPath] placeholderImage:model.avatarImage];
    } else {
        self.avatarView.image = model.avatarImage;
    }
}

- (void)setCustomBubbleView:(id<IMessageModel>)model{
    [_bubbleView setupViewPointBubbleView:model];
}

- (void)updateCustomBubbleViewMargin:(UIEdgeInsets)bubbleMargin model:(id<IMessageModel>)model{
    [_bubbleView updateViewPointMargin:bubbleMargin model:model];
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
