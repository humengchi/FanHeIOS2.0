//
//  SupplyAndNeedMyCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/9/4.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "SupplyAndNeedMyCell.h"

@implementation SupplyAndNeedMyCell
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
    
    CGFloat cotentWidth = 166;
    CGFloat sizeHeigth = 0;
    CGFloat y = 46;
    CGFloat height = [NSHelper heightOfString:ext[@"title"] font:[UIFont systemFontOfSize:12] width:cotentWidth];
    if (height < 46) {
         y = 56;
        sizeHeigth = height;
        height = 0;
    }else{
        sizeHeigth = 46;
        height = 16;
    }
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.avatarView.frame.origin.x+self.avatarView.frame.size.width, self.avatarView.frame.origin.y-5, 224, 90+height)];
        
        UIImage *bgImage = [[UIImage imageNamed:@"bg_card_tj1"] stretchableImageWithLeftCapWidth:25 topCapHeight:25];
        self.bgImage.userInteractionEnabled = YES;
        if (model.isSender) {
            self.bgImage.frame = CGRectMake(-15, self.avatarView.frame.origin.y- 5, 224, 90+height);
            bgImage = [[UIImage imageNamed:@"bg_card_tj2"] stretchableImageWithLeftCapWidth:25 topCapHeight:25];
        }
        self.bgImage.image = bgImage;
        [self.bubbleView addSubview:self.bgImage];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 12, cotentWidth, 16)];
        self.titleLabel.textColor = [UIColor colorWithHexString:@"41464E"];
        self.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.bgImage addSubview:self.titleLabel];
        
        
        self.postionLabel = [UILabel createLabel:CGRectMake(47, y, cotentWidth, sizeHeigth) font:[UIFont systemFontOfSize:12] bkColor:[UIColor clearColor] textColor:[UIColor colorWithHexString:@"818C9E"]];
        self.postionLabel.numberOfLines = 3;
        [self.bgImage addSubview:self.postionLabel];
      
        
        self.lineView = [[UIView alloc]initWithFrame:CGRectMake(12, 36, cotentWidth, 0.5)];
        self.lineView.backgroundColor = [UIColor colorWithHexString:@"D9D9D9"];
        [self.bgImage addSubview:self.lineView];
        
         self.headerImageView = [UIImageView drawImageViewLine:CGRectMake(14, 46, 29, 29) bgColor:[UIColor clearColor]];
        self.headerImageView.layer.masksToBounds = YES; //没这句话它圆不起来
        self.headerImageView.layer.cornerRadius = 14.5; //设置图片圆角的尺度
        self.headerImageView.layer.borderColor = HEX_COLOR(@"41464e").CGColor;
        
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
    self.titleLabel.text = [NSString stringWithFormat:@"%@的供需",ext[@"realName"]];
    self.postionLabel.text = ext[@"title"];

    self.bubbleView.backgroundImageView.hidden = YES;
}

+ (CGFloat)cellHeightWithModel:(id<IMessageModel>)model{
    NSDictionary *ext = model.message.ext;
    CGFloat cotentWidth = 166;
    CGFloat heigth = [NSHelper heightOfString:ext[@"companyPosition"] font:[UIFont systemFontOfSize:12] width:cotentWidth];
    if (heigth < 46) {
        heigth = 0;
    }else{
        heigth = 16;
    }
    return 120+heigth;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
