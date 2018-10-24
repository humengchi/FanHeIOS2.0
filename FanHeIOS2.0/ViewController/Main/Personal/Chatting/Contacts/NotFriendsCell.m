//
//  NotFriendsCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/9/12.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "NotFriendsCell.h"

@implementation NotFriendsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                        model:(id<IMessageModel>)model{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier model:model];
    //    [self configureLayoutConstraintsWithModel:model];
    
    if ([UIDevice currentDevice].systemVersion.floatValue == 7.0) {
        self.messageNameHeight = 15;
    }
    self.bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.avatarView.frame.origin.x+self.avatarView.frame.size.width+4, self.avatarView.frame.origin.y - 6, 228, 120)];
    self.headerImageView = [UIImageView drawImageViewLine:CGRectMake(14, self.titleLabel.frame.origin.y + 12 + 10, 29, 29) bgColor:[UIColor clearColor]];
    return self;
}

@end
