//
//  HotRateViewCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/17.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "HotRateViewCell.h"

@implementation HotRateViewCell
- (void)tranferFianaceDetailModel:(FinanaceDetailModel *)model{
    self.model = model;
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefault];
    self.headerImageView.userInteractionEnabled = YES;
    self.headerImageView.tag = self.
    self.headerImageView.layer.masksToBounds = YES;
    self.headerImageView.layer.cornerRadius = self.headerImageView.frame.size.width/2.0;
    self.positionLabel.text = [NSString stringWithFormat:@"%@%@",model.company,model.position];
    if (model.praisecount.integerValue > 10000) {
        self.rateCountLabel.text = [NSString stringWithFormat:@"%ld万",model.praisecount.integerValue/10000];
    }else{
        self.rateCountLabel.text = [NSString stringWithFormat:@"%ld",model.praisecount.integerValue];
    }
    if (self.secoundType == YES) {
        self.rateCountLabel.hidden = YES;
        self.likeRateBtn.hidden = YES;
    }
    self.nameLabel.text = model.realname;
    if (model.usertype.integerValue != 9) {
        self.memberImageView.hidden = YES;
    }
    if (model.othericon.integerValue != 1) {
        self.intVisiyionImageViwe.hidden = YES;
    }
    if(model.ispraise.integerValue == 1) {
        self.likeRateBtn.selected = YES;
        self.rateCountLabel.textColor = [UIColor colorWithHexString:@"E24943"];
    }else{
        self.likeRateBtn.selected = NO;
    }
    if(self.headerAttentBtn){
        self.headerAttentBtn.selected = self.model.isattention.integerValue;
    }
    
    self.backName.userInteractionEnabled = YES;
    self.backName.attributedText =  [self tranferStrPhone:[NSString stringWithFormat:@"回复 %@",model.replyname] length:model.replyname];
    
    
    self.contentLabel.text = model.content;
    self.timeLabel.text = model.created_at;
    if (model.reviewcount.integerValue > 0 && model.reviewcount.integerValue < 10000) {
        self.typeLabel.text = [NSString stringWithFormat:@"评论 %ld",model.reviewcount.integerValue];
    }else if (model.reviewcount.integerValue >= 10000){
        self.typeLabel.text = [NSString stringWithFormat:@"评论 %ld万",model.reviewcount.integerValue/10000];
    }else{
        if ([DataModelInstance shareInstance].userModel.userId.integerValue == model.userid.integerValue) {
            self.typeLabel.text = @"删除";
            self.typeLabel.textColor = [UIColor colorWithHexString:@"E24943"];
        }else{
            self.typeLabel.text = @"回复";
        }
    }
    self.contentLabel.tag = self.indePathRow;
    self.likeRateBtn.tag = self.indePathRow;
    self.typeLabel.tag = self.indePathRow;
    self.typeLabel.userInteractionEnabled = YES;
    self.contentLabel.userInteractionEnabled = YES;
}
+ (CGFloat)backHotRateViewCell:(FinanaceDetailModel *)model{
    CGFloat heigth = 112;
    CGFloat heigth1 = [NSHelper heightOfString:model.content font:[UIFont systemFontOfSize:14] width:WIDTH - 69 - 16];
    if (model.realname.length > 0) {
        heigth1 += 20;
    }
    return heigth + heigth1;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (IBAction)attentionBtnAction:(UIButton *)sender {
    if(self.model.isattention.integerValue==1){
        [[self viewController].view showToastMessage:@"你已经关注过啦"];
        return;
    }
    sender.selected = YES;
    self.model.isattention = @(1);
    if([self.hotRateViewCellDelegate respondsToSelector:@selector(attentionTapAction)]){
        [self.hotRateViewCellDelegate attentionTapAction];
    }
}

- (IBAction)likeCountBtnAction:(UIButton *)sender {
    NSInteger index = sender.tag;
    if ([self.hotRateViewCellDelegate respondsToSelector:@selector(likePraiseBtnAction: hotRate:)]) {
        [self.hotRateViewCellDelegate likePraiseBtnAction:index hotRate:self.model.hotRateStart];
    }
}

- (IBAction)delectRateTapAction:(UITapGestureRecognizer *)sender {
    NSInteger index = sender.view.tag;
    if ([self.hotRateViewCellDelegate respondsToSelector:@selector(delectOrRateTapAction: hotRate:)]) {
        [self.hotRateViewCellDelegate delectOrRateTapAction:index hotRate:self.model.hotRateStart];
    }
}

- (IBAction)longTapAction:(UILongPressGestureRecognizer *)sender {
    NSInteger index = sender.view.tag;
    if ([self.hotRateViewCellDelegate respondsToSelector:@selector(longPreaaTapAction: hotRate:)]) {
        [self.hotRateViewCellDelegate longPreaaTapAction:index hotRate:self.model.hotRateStart];
    }
}

- (IBAction)replayNameHisMainPage:(id)sender {
    NewMyHomePageController *myHome = [[NewMyHomePageController alloc]init];
    myHome.userId = self.model.replyid;
    [[self viewController].navigationController pushViewController:myHome animated:YES];
}

- (IBAction)intViewHisPage:(UITapGestureRecognizer *)sender {
    NewMyHomePageController *myHome = [[NewMyHomePageController alloc]init];
    myHome.userId = self.model.userid;
    if(self.headerAttentBtn.isHidden==NO){
        myHome.attentUser = ^(BOOL isAttent){
            self.model.isattention = [NSNumber numberWithBool:isAttent];
            self.headerAttentBtn.selected = isAttent;
        };
    }
    [[self viewController].navigationController pushViewController:myHome animated:YES];
}

- (NSMutableAttributedString *)tranferStrPhone:(NSString *)str length:(NSString *)length{
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:str];
    [AttributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"4393E2"] range:NSMakeRange(str.length - length.length,length.length)];
    
    return AttributedStr;
}
- (IBAction)likeRateActionONe:(UITapGestureRecognizer *)sender {
    NSInteger index = sender.view.tag;
    if ([self.hotRateViewCellDelegate respondsToSelector:@selector(delectOrRateTapAction: hotRate:)]) {
        [self.hotRateViewCellDelegate delectOrRateTapAction:index hotRate:self.model.hotRateStart];
    }
}

@end
