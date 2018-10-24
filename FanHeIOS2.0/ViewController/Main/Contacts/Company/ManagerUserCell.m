//
//  ManagerUserCell.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/26.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ManagerUserCell.h"

@interface ManagerUserCell ()

@property (weak, nonatomic) IBOutlet UIImageView *rzImageView;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIImageView *vipImageView;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;

@end

@implementation ManagerUserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [CALayer updateControlLayer:self.headImageView.layer radius:32 borderWidth:0 borderColor:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateDisplayUserModel:(UserModel*)model{
    self.rzImageView.hidden = model.hasValidUser.integerValue != 1;
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
    self.vipImageView.hidden = model.othericon.integerValue != 1;
    self.positionLabel.text = model.position;
    self.nameLabel.text = model.realname;
    self.introLabel.text = model.intro.length?model.intro:@"个人简介";
}

@end
