
//  ActivityInviteCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/25.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ActivityInviteCell.h"

@implementation ActivityInviteCell
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
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                        model:(id<IMessageModel>)model{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier model:model];
    if ([UIDevice currentDevice].systemVersion.floatValue == 7.0) {
        self.messageNameHeight = 15;
    }
    NSDictionary *ext = model.message.ext;
    MyActivityModel *actModel = [[MyActivityModel alloc] initWithDict:ext];
    self.wideth = self.contentView.frame.size.width - 29 - 6;
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.avatarView.frame.origin.x+self.avatarView.frame.size.width, self.avatarView.frame.origin.y - 5, 224, 125)];
        UIImage *bgImage = [[UIImage imageNamed:@"bg_card_tj1"] stretchableImageWithLeftCapWidth:25 topCapHeight:25];
        self.bgImage.userInteractionEnabled = YES;
        if (model.isSender) {
            self.bgImage.frame = CGRectMake(4, self.avatarView.frame.origin.y-10, 224, 125);
            bgImage = [[UIImage imageNamed:@"bg_card_tj2"] stretchableImageWithLeftCapWidth:25 topCapHeight:25];
        }
        self.bgImage.image = bgImage;
        [self.bubbleView addSubview:self.bgImage];
        
        UILabel *hudLabel = [UILabel createLabel:CGRectMake(12, 12, 166, 19) font:[UIFont systemFontOfSize:16] bkColor:[UIColor clearColor] textColor:[UIColor colorWithHexString:@"f76b1c"]];
        hudLabel.text = @"邀请你参加活动：";
        if (!model.isSender) {
            UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 38, self.bgImage.frame.size.width - 32, 0.5)];
            lineLabel.backgroundColor = kCellLineColor;
            [self.bgImage addSubview:lineLabel];
        }else{
            UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 38, self.bgImage.frame.size.width - 32, 0.5)];
            lineLabel.backgroundColor = kCellLineColor;
            [self.bgImage addSubview:lineLabel];
        }
        [self.bgImage addSubview:hudLabel];
        
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 50, 200, 17)];
        self.titleLabel.text = actModel.name;
        self.titleLabel.textColor = HEX_COLOR(@"41464e");
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.bgImage addSubview:self.titleLabel];
        
        self.timeLabel = [UILabel createLabel:CGRectMake(12, 75, 200, 15) font:[UIFont systemFontOfSize:12] bkColor:[UIColor clearColor] textColor:KTextColor];
        self.timeLabel.numberOfLines = 1;
        self.timeLabel.text = [NSString stringWithFormat:@"%@ 至 %@", actModel.starttime, actModel.endtime];
        [self.bgImage addSubview:self.timeLabel];
        
        self.addressLabel = [UILabel createLabel:CGRectMake(12, 97, 200, 15) font:[UIFont systemFontOfSize:12] bkColor:[UIColor clearColor] textColor:KTextColor];
        self.addressLabel.numberOfLines = 1;
        self.addressLabel.text = actModel.address;
        [self.bgImage addSubview:self.addressLabel];
        
    }
    return self;
}

- (void)setModel:(id<IMessageModel>)model{
    [super setModel:model];
    NSDictionary *ext = model.message.ext;
    MyActivityModel *actModel = [[MyActivityModel alloc] initWithDict:ext];
    self.titleLabel.text = actModel.name;
    self.timeLabel.text =  actModel.starttime;
    self.addressLabel.text = actModel.address;
    self.bubbleView.backgroundImageView.hidden = YES;
}

@end
