//
//  JoinGroupCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/9/4.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "JoinGroupCell.h"

@implementation JoinGroupCell

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
    
    if (self) {
        CGFloat wideth = [NSHelper widthOfString: ext[@"title"] font:[UIFont systemFontOfSize:10] height:10]+20;
        if ( wideth > WIDTH - 80) {
            wideth = WIDTH - 80;
        }
        self.backgroundColor = [UIColor clearColor];
        self.bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(40, self.avatarView.frame.origin.y + 10, wideth, 20)];
        self.bgImage.backgroundColor = [UIColor colorWithHexString:@"AFB6C1"];
        self.bgImage.layer.masksToBounds = YES; //没这句话它圆不起来
        self.bgImage.layer.cornerRadius = 12; //设置图片圆角的尺度

        self.bgImage.userInteractionEnabled = YES;
        if (model.isSender) {
            self.bgImage.frame = CGRectMake(40, self.avatarView.frame.origin.y + 10, wideth, 20);

        }
        [self.bubbleView addSubview:self.bgImage];
        
       
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, wideth - 20, 10)];
        self.titleLabel.textColor = [UIColor colorWithHexString:@"FFFFFF"];
        self.titleLabel.font = [UIFont systemFontOfSize:10];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.bgImage addSubview:self.titleLabel];
        
        
        self.avatarView.image = [UIImage imageNamed:@"icon_avatar_jmxms_round"];
    }
    return self;
}

- (void)setModel:(id<IMessageModel>)model{
    [super setModel:model];
    NSDictionary *ext = model.message.ext;

    self.titleLabel.text = ext[@"title"];
    
    self.bubbleView.backgroundImageView.hidden = YES;
}

+ (CGFloat)cellHeightWithModel:(id<IMessageModel>)model{
    //    NSDictionary *ext = model.message.ext;
    //    CGFloat cotentWidth = 166;
    //       CGFloat heigth = [NSHelper heightOfString:ext[@"companyPosition"] font:[UIFont systemFontOfSize:12] width:cotentWidth];
    return 40;
    
}

@end
