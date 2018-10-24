
//  SendCardCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/25.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "SendCardCell.h"

@implementation SendCardCell
+ (void)initialize
{
    // UIAppearance Proxy Defaults
    EaseBaseMessageCell *cell = [self appearance];
    cell.avatarSize = 30;
    cell.avatarCornerRadius = 0;
    
    cell.messageNameColor = [UIColor grayColor];
    cell.messageNameFont = [UIFont systemFontOfSize:10];
    cell.messageNameHeight = 15;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        cell.messageNameIsHidden = NO;
    }
    //    cell.backgroundColor = HEX_COLOR(@"F7F7F7");
    //     cell.backgroundColor = HEX_COLOR(@"ff0000");
    //    cell.bubbleMargin = UIEdgeInsetsMake(8, 15, 8, 10);
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                        model:(id<IMessageModel>)model
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier model:model];
    //    [self configureLayoutConstraintsWithModel:model];
    
    if ([UIDevice currentDevice].systemVersion.floatValue == 7.0) {
        self.messageNameHeight = 15;
    }
    NSDictionary *ext = model.message.ext;
    CGFloat heigth = [NSHelper heightOfString:ext[@"positionStr"] font:[UIFont systemFontOfSize:12] width:166];
    self.wideth = self.contentView.frame.size.width - 29 - 6;
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.avatarView.frame.origin.x+self.avatarView.frame.size.width, self.avatarView.frame.origin.y-5, 224, 120)];
        if (heigth > 28) {
            self.bgImage.frame = CGRectMake(self.avatarView.frame.origin.x+self.avatarView.frame.size.width, self.avatarView.frame.origin.y-5, 224, 140);
        }
        UIImage *bgImage = [[UIImage imageNamed:@"bg_card_tj1"] stretchableImageWithLeftCapWidth:25 topCapHeight:25];
        self.bgImage.userInteractionEnabled = YES;
        if (model.isSender) {
            self.bgImage.frame = CGRectMake(-26+6, self.avatarView.frame.origin.y-10, 224, 120);
            if (heigth > 28) {
                self.bgImage.frame =CGRectMake(-26+6, self.avatarView.frame.origin.y-10, 224, 140);
            }
            bgImage = [[UIImage imageNamed:@"bg_card_tj2"] stretchableImageWithLeftCapWidth:25 topCapHeight:25];
        }
        self.bgImage.image = bgImage;
        [self.bubbleView addSubview:self.bgImage];
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 12, 210, 12)];
        self.titleLabel.text = @"推荐好友";
        self.titleLabel.textColor = [UIColor colorWithHexString:@"41464E"];
        self.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.bgImage addSubview:self.titleLabel];
        self.headerImageView = [UIImageView drawImageViewLine:CGRectMake(14, self.titleLabel.frame.origin.y + 12 + 15 + 12, 29, 29) bgColor:[UIColor clearColor]];
        self.headerImageView.layer.masksToBounds = YES; //没这句话它圆不起来
        self.headerImageView.layer.cornerRadius = 14.5; //设置图片圆角的尺度
        [self.bgImage addSubview:self.headerImageView];
        self.locationLabel = [UILabel createLabel:CGRectMake(self.headerImageView.frame.origin.x + 29+6, 36+12, 166, heigth) font:[UIFont systemFontOfSize:12] bkColor:[UIColor clearColor] textColor:[UIColor colorWithHexString:@"41464E"]];
        self.locationLabel.numberOfLines = 0;
        [self.bgImage addSubview:self.locationLabel];
        self.postionLabel = [UILabel createLabel:CGRectMake(self.locationLabel.frame.origin.x, self.locationLabel.frame.size.height+self.locationLabel.frame.origin.y+6, self.locationLabel.frame.size.width, 12) font:[UIFont systemFontOfSize:12] bkColor:[UIColor clearColor] textColor:[UIColor colorWithHexString:@"818C9E"]];
        [self.bgImage addSubview:self.postionLabel];
        self.lineView = [[UIView alloc]initWithFrame:CGRectMake(16, self.titleLabel.frame.size.height + self.titleLabel.frame.origin.y +12, self.bgImage.frame.size.width - 32, 0.5)];
        self.lineView.backgroundColor = [UIColor colorWithHexString:@"D9D9D9"];
        [self.bgImage addSubview:self.lineView];
        self.goodAtLabel = [UILabel createLabel:CGRectMake(12, self.postionLabel.frame.size.height + self.postionLabel.frame.origin.y + 12, self.contentView.frame.size.width - 120, 12) font:[UIFont systemFontOfSize:12] bkColor:[UIColor clearColor] textColor:[UIColor colorWithHexString:@"2980B9"]];
        self.goodAtLabel.numberOfLines = 0;
        [self.bgImage addSubview:self.goodAtLabel];
        self.avatarView.image = [UIImage imageNamed:@"icon_avatar_jmxms_round"];
        if ([UIDevice currentDevice].systemVersion.floatValue == 7.0) {
            self.messageNameHeight = 15;
        }
        
    }
    return self;
}

- (void)setModel:(id<IMessageModel>)model{
    [super setModel:model];
    NSDictionary *ext = model.message.ext;
    
    if (ext[@"imagUrl"]) {
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:ext[@"imagUrl"]] placeholderImage:KHeadImageDefaultName(ext[@"positionStr"])];
    } else {
        self.headerImageView.image = model.avatarImage;
    }
    self.locationLabel.text = ext[@"positionStr"];
    self.postionLabel.text = ext[@"name"];
    self.goodAtLabel.text =ext[@"gooAtStr"];
    self.bubbleView.backgroundImageView.hidden = YES;
}

+ (CGFloat)cellHeightWithModel:(id<IMessageModel>)model{
    NSDictionary *ext = model.message.ext;
    CGFloat heigth = [NSHelper heightOfString:ext[@"positionStr"] font:[UIFont systemFontOfSize:12] width:166];
    if (heigth > 28) {
        return 155 + heigth;
    }
    return 144 + heigth;
    
}

@end
