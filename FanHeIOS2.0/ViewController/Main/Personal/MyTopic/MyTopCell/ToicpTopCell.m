//
//  ToicpTopCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/20.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ToicpTopCell.h"

@implementation ToicpTopCell
- (void)createrToicpTopCell:(NSInteger)index{
    
    self.acountLabel.layer.masksToBounds = YES;
    self.acountLabel.layer.cornerRadius =  9.0;
    NSArray *imageArray =  @[@"icon_mytopic_message",@"icon_mytopic_comment",@"icon_mytopic_faqi"];
    NSArray *titleArray = @[@"话题通知",@"我的观点&评论",@"我发起的话题"];
    self.coverImageView.image = kImageWithName(imageArray[index]);
    self.titleLabel.text = titleArray[index];
    
    
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
