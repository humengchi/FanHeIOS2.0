//
//  NewLookHistoryCell.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/14.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "NewLookHistoryCell.h"

@interface NewLookHistoryCell ()

@property (weak, nonatomic) IBOutlet UIImageView *rzImageView;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIImageView *vipImageView;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *tagsView;
@end

@implementation NewLookHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateDisplayModel:(LookHistoryModel*)model{
    self.rzImageView.hidden = model.hasValidUser.integerValue != 1;
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
    self.vipImageView.hidden = model.othericon.integerValue != 1;
    self.companyLabel.text = model.company;
    self.nameLabel.text = model.realname;
    
    for(UIView *view in self.tagsView.subviews){
        [view removeFromSuperview];
    }
    CGFloat start_X = 0;
    if([CommonMethod paramStringIsNull:model.relation].length){
        CGFloat strWidth = [NSHelper widthOfString:model.relation font:FONT_SYSTEM_SIZE(8) height:11]+15;
        UILabel *realtionLabel = [UILabel createrLabelframe:CGRectMake(start_X, 0, strWidth, 11) backColor:WHITE_COLOR textColor:HEX_COLOR(@"818c9e") test:model.relation font:8 number:1 nstextLocat:NSTextAlignmentCenter];
        [CALayer updateControlLayer:realtionLabel.layer radius:5.5 borderWidth:0.3 borderColor:HEX_COLOR(@"818c9e").CGColor];
        [self.tagsView addSubview:realtionLabel];
        start_X += strWidth+6;
    }
    if([CommonMethod paramNumberIsNull:model.usertype].integerValue == 9){
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(start_X, 0, 31, 11)];
        iconImageView.image = kImageWithName(@"icon_zy_zf");
        [self.tagsView addSubview:iconImageView];
    }
}

- (void)updateDisplayUserModel:(UserModel*)model{
    self.rzImageView.hidden = model.hasValidUser.integerValue != 1;
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
    self.vipImageView.hidden = model.othericon.integerValue != 1;
    self.companyLabel.text = model.company;
    self.nameLabel.text = model.realname;
    
    for(UIView *view in self.tagsView.subviews){
        [view removeFromSuperview];
    }
    CGFloat start_X = 0;
    if([CommonMethod paramStringIsNull:model.relation].length){
        CGFloat strWidth = [NSHelper widthOfString:model.relation font:FONT_SYSTEM_SIZE(8) height:11]+15;
        UILabel *realtionLabel = [UILabel createrLabelframe:CGRectMake(start_X, 0, strWidth, 11) backColor:WHITE_COLOR textColor:HEX_COLOR(@"818c9e") test:model.relation font:8 number:1 nstextLocat:NSTextAlignmentCenter];
        [CALayer updateControlLayer:realtionLabel.layer radius:5.5 borderWidth:0.3 borderColor:HEX_COLOR(@"818c9e").CGColor];
        [self.tagsView addSubview:realtionLabel];
        start_X += strWidth+6;
    }
    if([CommonMethod paramNumberIsNull:model.usertype].integerValue == 9){
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(start_X, 0, 31, 11)];
        iconImageView.image = kImageWithName(@"icon_zy_zf");
        [self.tagsView addSubview:iconImageView];
    }
}

@end
