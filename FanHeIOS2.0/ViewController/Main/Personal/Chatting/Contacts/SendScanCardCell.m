
//  SendScanCardCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/25.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "SendScanCardCell.h"

@implementation SendScanCardCell

+ (void)initialize{
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
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                        model:(id<IMessageModel>)model{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier model:model];
    
    NSDictionary *ext = model.message.ext;
    
    CGFloat cotentWidth = 192;
    if(!model.isSender){
        cotentWidth = 200;
    }
    CGFloat height = [NSHelper heightOfString:ext[@"companyPosition"] font:[UIFont systemFontOfSize:12] width:cotentWidth];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.avatarView.frame.origin.x+self.avatarView.frame.size.width, self.avatarView.frame.origin.y-5, 224, 185+height)];
        
        UIImage *bgImage = [[UIImage imageNamed:@"bg_card_tj1"] stretchableImageWithLeftCapWidth:25 topCapHeight:25];
        self.bgImage.userInteractionEnabled = YES;
        if (model.isSender) {
            self.bgImage.frame = CGRectMake(-20 - 14, self.avatarView.frame.origin.y-10 + 5, 224, 185+height);
            bgImage = [[UIImage imageNamed:@"bg_card_tj2"] stretchableImageWithLeftCapWidth:25 topCapHeight:25];
        }
        self.bgImage.image = bgImage;
        [self.bubbleView addSubview:self.bgImage];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 12, cotentWidth, 16)];
        self.titleLabel.text = ext[@"title"];
        self.titleLabel.textColor = [UIColor colorWithHexString:@"41464E"];
        self.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.bgImage addSubview:self.titleLabel];
        
        self.postionLabel = [UILabel createLabel:CGRectMake(12, 37, cotentWidth, height) font:[UIFont systemFontOfSize:12] bkColor:[UIColor clearColor] textColor:[UIColor colorWithHexString:@"818C9E"]];
        self.postionLabel.text = ext[@"companyPosition"];
        [self.bgImage addSubview:self.postionLabel];
        
        self.lineView = [[UIView alloc]initWithFrame:CGRectMake(12, 37+height+10, cotentWidth, 0.5)];
        self.lineView.backgroundColor = [UIColor colorWithHexString:@"D9D9D9"];
        [self.bgImage addSubview:self.lineView];

        self.headerImageView = [UIImageView drawImageViewLine:CGRectMake(12, 37+height+10+10, cotentWidth, 113) bgColor:[UIColor clearColor]];
        self.headerImageView.layer.masksToBounds = YES; //没这句话它圆不起来
        self.headerImageView.layer.cornerRadius = 4; //设置图片圆角的尺度
        self.headerImageView.layer.borderColor = HEX_COLOR(@"41464e").CGColor;
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:ext[@"imageUrl"]] placeholderImage:kImageWithName(@"mr_mp_mptu")];
        self.headerImageView.layer.borderWidth = 0.5;
        self.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.headerImageView.clipsToBounds = YES;
        [self.bgImage addSubview:self.headerImageView];
        
        self.avatarView.image = [UIImage imageNamed:@"icon_avatar_jmxms_round"];
    }
    return self;
}

- (void)setModel:(id<IMessageModel>)model{
    [super setModel:model];
    NSDictionary *ext = model.message.ext;
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:ext[@"imageUrl"]] placeholderImage:kImageWithName(@"mr_mp_mptu")];
    self.titleLabel.text = ext[@"title"];
    self.postionLabel.text = ext[@"companyPosition"];
    self.bubbleView.backgroundImageView.hidden = YES;
}

+ (CGFloat)cellHeightWithModel:(id<IMessageModel>)model{
    NSDictionary *ext = model.message.ext;
    CGFloat cotentWidth = 202;
    if(!model.isSender){
        cotentWidth = 200;
    }
    CGFloat heigth = [NSHelper heightOfString:ext[@"companyPosition"] font:[UIFont systemFontOfSize:12] width:cotentWidth];
    return 200 + heigth;
    
}

@end
