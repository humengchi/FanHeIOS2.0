//
//  ActivityChatCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/3/10.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ActivityChatCell.h"
#import "EaseBubbleView+Activity.h"
@implementation ActivityChatCell
//+ (void)initialize
//{
//    // UIAppearance Proxy Defaults
//    EaseBaseMessageCell *cell = [self appearance];
//    cell.avatarSize = 30;
//    cell.avatarCornerRadius = 0;
//    
//    cell.messageNameColor = [UIColor grayColor];
//    cell.messageNameFont = [UIFont systemFontOfSize:10];
//    cell.messageNameHeight = 15;
//    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
//        cell.messageNameIsHidden = NO;
//    }
//    
//}
//
//- (instancetype)initWithStyle:(UITableViewCellStyle)style
//              reuseIdentifier:(NSString *)reuseIdentifier
//                        model:(id<IMessageModel>)model
//{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier model:model];
//    //    [self configureLayoutConstraintsWithModel:model];
//    
//    if ([UIDevice currentDevice].systemVersion.floatValue == 7.0) {
//        self.messageNameHeight = 15;
//    }
//    
//    self.wideth = self.contentView.frame.size.width - 29 - 6;
//    if (self) {
//        self.backgroundColor = [UIColor clearColor];
//        self.bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.avatarView.frame.origin.x+self.avatarView.frame.size.width, self.avatarView.frame.origin.y , 220, 72)];
//       
//        UIImage *bgImage = [[UIImage imageNamed:@"bg_card_tj1"] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
//        self.bgImage.userInteractionEnabled = YES;
//        if (model.isSender) {
//            self.bgImage.frame = CGRectMake(-60, self.avatarView.frame.origin.y, 220, 72);
//          
//            bgImage = [[UIImage imageNamed:@"bg_card_tj2"] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
//        }
//        self.bgImage.image = bgImage;
//        [self.bubbleView addSubview:self.bgImage];
//        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 12, 200, 12)];
//        self.titleLabel.textColor = [UIColor colorWithHexString:@"41464E"];
//        self.titleLabel.font = [UIFont systemFontOfSize:15];
//        [self.bgImage addSubview:self.titleLabel];
//        
//        self.countLabel =  [[UILabel alloc] initWithFrame:CGRectMake(14, 42, 200, 16)];
//        self.countLabel.numberOfLines = 1;
//        self.countLabel.textColor = [UIColor colorWithHexString:@"41464E"];
//        self.countLabel.font = [UIFont systemFontOfSize:12];
//        [self.bgImage addSubview:self.countLabel];
//        
//        
//        self.lineView = [[UIView alloc]initWithFrame:CGRectMake(16, 36, self.bgImage.frame.size.width - 32, 0.5)];
//        self.lineView.backgroundColor = [UIColor colorWithHexString:@"D9D9D9"];
//        [self.bgImage addSubview:self.lineView];
//        
//        self.avatarView.image = [UIImage imageNamed:@"icon_avatar_jmxms_round"];
//        if ([UIDevice currentDevice].systemVersion.floatValue == 7.0) {
//            self.messageNameHeight = 15;
//        }
//        
//    }
//    return self;
//}
//


- (void)setCustomModel:(id<IMessageModel>)model
{
    NSDictionary *ext = model.message.ext;
    self.bubbleView.countLabel.text = ext[@"title"];
    NSString *str = ext[@"count"];
    self.bubbleView.titleLabel.text =  [str filterHTML];
}

- (BOOL)isCustomBubbleView:(id<IMessageModel>)model
{
    return YES;
}

- (void)setCustomBubbleView:(id<IMessageModel>)model
{
    [_bubbleView setupActivityBubbleView:model];
}

- (void)updateCustomBubbleViewMargin:(UIEdgeInsets)bubbleMargin model:(id<IMessageModel>)model
{
    
    [_bubbleView updateActivityMargin:bubbleMargin model:model];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
