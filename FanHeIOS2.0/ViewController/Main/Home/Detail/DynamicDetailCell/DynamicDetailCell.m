//
//  DynamicDetailCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/3/1.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "DynamicDetailCell.h"

@implementation DynamicDetailCell

- (void)tranferFianaceDetailModel:(FinanaceDetailModel *)model{
    self.model = model;
    self.headerImageView.userInteractionEnabled = YES;
    self.headerImageView.tag = self.
    self.headerImageView.layer.masksToBounds = YES;
    self.headerImageView.layer.cornerRadius = self.headerImageView.frame.size.width/2.0;
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
    NSString *str1 = [NSString stringWithFormat:@"%@%@",model.company,model.position];
    self.realeNameLabel.text = model.realname;
    if (str1.length > 0) {
        self.positionLabel.text = str1;
        self.segLabel.hidden = YES;
        self.verImageView1.hidden = YES;
    }else{
        self.segLabel.text = model.realname;
        self.realeNameLabel.hidden = YES;
        self.positionLabel.hidden = YES;
        if (model.othericon.integerValue != 1) {
            self.verImageView1.hidden = YES;
        }
            self.interviewImageView.hidden = YES;
    }
  
    if (model.praisecount.integerValue > 10000) {
        self.printecountLabel.text = [NSString stringWithFormat:@"%ld万",model.praisecount.integerValue/10000];
    }else{
        self.printecountLabel.text = [NSString stringWithFormat:@"%ld",model.praisecount.integerValue];
    }
    
    
    if (model.usertype.integerValue != 9) {
        self.approveImageView.hidden = YES;
    }
    if (model.othericon.integerValue != 1) {
        self.interviewImageView.hidden = YES;
    }
    NSString *str = model.replyto[@"realname"];
    if (str.length > 0) {
        self.backLabel.attributedText =  [self tranferStrPhone:[NSString stringWithFormat:@"回复 %@",model.replyto[@"realname"]] length:model.replyto[@"realname"]];
    }
    self.countLabel.text = model.content;
    NSString *startTime = model.created_at;
    if (model.created_at.length > 11) {
        startTime = [model.created_at substringToIndex:10];
    }
     self.timeLabel.text = startTime;
    
    if (model.reviewcount.integerValue > 0 && model.reviewcount.integerValue < 10000) {
        self.stateLabel.text = [NSString stringWithFormat:@"评论 %ld",model.reviewcount.integerValue];
    }else if (model.reviewcount.integerValue >= 10000){
        self.stateLabel.text = [NSString stringWithFormat:@"评论 %ld万",model.reviewcount.integerValue/10000];
    }else{
        if ([DataModelInstance shareInstance].userModel.userId.integerValue == model.userid.integerValue) {
            self.stateLabel.text = @"删除";
            self.stateLabel.textColor = [UIColor colorWithHexString:@"E24943"];
        }else{
            self.stateLabel.text = @"回复";
        }
    }
    if (model.ispraise.integerValue == 1) {
        self.likeBtn.selected = YES;
        self.printecountLabel.textColor = [UIColor colorWithHexString:@"E24943"];
    }else{
        self.likeBtn.selected = NO;
    }
    self.countLabel.tag = self.indePathRow;
    self.likeBtn.tag = self.indePathRow;
    self.stateLabel.tag = self.indePathRow;
    self.stateLabel.userInteractionEnabled = YES;
    self.countLabel.userInteractionEnabled = YES;
}

- (IBAction)delectRateOrRate:(UITapGestureRecognizer *)sender {
    NSInteger index = sender.view.tag;
    if ([self.dynamicDetailCellDelegate respondsToSelector:@selector(delectOrRateTapAction:)]) {
        [self.dynamicDetailCellDelegate delectOrRateTapAction:index];
    }
}

- (IBAction)likeAction:(UIButton *)sender {
    NSInteger index = sender.tag;
    if ([self.dynamicDetailCellDelegate respondsToSelector:@selector(likePraiseBtnAction:)]) {
        [self.dynamicDetailCellDelegate likePraiseBtnAction:index];
    }
}

#pragma mark ------ 长按复制举报
- (IBAction)longTapCopyAction:(UILongPressGestureRecognizer *)sender {
    NSInteger index = sender.view.tag;
    self.countLabel.backgroundColor = [UIColor colorWithHexString:@"E0E0E0"];
    if ([self.dynamicDetailCellDelegate respondsToSelector:@selector(longPreaaTapAction:)]) {
        [self.dynamicDetailCellDelegate longPreaaTapAction:index];
    }
}

#pragma mark ---- 去他的主页
- (IBAction)gotoHisPage:(id)sender {
    NewMyHomePageController *myHome = [[NewMyHomePageController alloc]init];
    myHome.userId = self.model.userid;
    [[self viewController].navigationController pushViewController:myHome animated:YES];
}

+ (CGFloat)backHotRateViewCell:(FinanaceDetailModel *)model{
    CGFloat heigth = 106;
    CGFloat heigth1 = [NSHelper heightOfString:model.content font:[UIFont systemFontOfSize:14] width:WIDTH - 69 - 16];
    if (model.realname.length > 0) {
        heigth1 += 36;
    }
    NSString *str = model.replyto[@"realname"];
    if (str.length > 0){
        return heigth + heigth1;
    }
    return heigth + heigth1 - 20;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (NSMutableAttributedString *)tranferStrPhone:(NSString *)str length:(NSString *)length{
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:str];
    [AttributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"4393E2"] range:NSMakeRange(str.length - length.length,length.length)];
    return AttributedStr;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
