//
//  LookHistoryCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/10/28.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "LookHistoryCell.h"

@implementation LookHistoryCell


- (void)lookHistoryModel:(LookHistoryModel *)model{
    self.viteryImageView.hidden = model.usertype.integerValue != 9;
    if (self.isMyPage) {
        self.timeLabel.text = model.visitedtime;
    }else{
        self.timeLabel.hidden = YES;
    }
    if (model.hasValidUser.integerValue != 1) {
        self.resignImageView.hidden = YES;
    }
    self.subjectImageView.hidden = model.othericon.integerValue != 1;
    NSString *position = [NSString stringWithFormat:@"%@%@",model.company,model.position];
    if (position.length > 0) {
        self.companyLabel.text = position;
         self.nameLabel.text = model.realname;
        self.onlyNameLabel.hidden = YES;
        self.nameLabel.hidden = NO;
        self.companyLabel.hidden = NO;
    }else{
        self.nameLabel.hidden = YES;
        self.companyLabel.hidden = YES;
        self.companyLabel.text = @"公司职位";
        self.onlyNameLabel.hidden = NO;
        self.onlyNameLabel.text = model.realname;
    }
   
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
    
    if(model.applyid.integerValue){
        self.arrowImageView.hidden = NO;
    }
    if (self.isApply) {
        self.arrowImageView.hidden = YES;
    }
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.headerImageView.layer.masksToBounds = YES; //没这句话它圆不起来
    self.headerImageView.layer.cornerRadius = 22; //设置图片圆角的尺度
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
