//
//  ActivityAboutreadCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/10.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ActivityAboutreadCell.h"
#import "ActivityDetailController.h"
@implementation ActivityAboutreadCell
- (IBAction)likeBtnAction1:(UITapGestureRecognizer *)sender {
    if ([self.activityAboutreadCellDelegate respondsToSelector:@selector(likeTapActionBtn)]) {
        [self.activityAboutreadCellDelegate likeTapActionBtn];
    }

}
- (void)tranferActivityAboutreadCellModel:(FinanaceDetailModel *)model{
    self.model = model;
    CGFloat gX = 16;
    CGFloat gY = 0;
    self.tagLabel.userInteractionEnabled = YES;
    for (NSInteger i = 0; i < model.tags.count; i++) {
        CGFloat wideth = [NSHelper widthOfString:model.tags[i] font:[UIFont systemFontOfSize:13] height:20] + 8;
        UILabel *label = [[UILabel alloc]init];
        label.font = [UIFont systemFontOfSize:13];
        label.text = model.tags[i];
        label.textColor = [UIColor colorWithHexString:@"1ABC9C"];
        label.textAlignment = NSTextAlignmentCenter;
        label.layer.cornerRadius = 2;
        label.layer.borderWidth = 0.5;
        label.layer.borderColor = [UIColor colorWithHexString:@"1ABC9C"].CGColor;
        
        label.frame = CGRectMake(gX, gY, wideth, 28);
        gX = gX + wideth + 6 ;
        label.tag = i;
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapg = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(searchTag:)];
        [label addGestureRecognizer:tapg];
        [self.tagLabel addSubview:label];
    }
    self.timeLabel.text = model.created_at;
    self.likeCountLabel.text = [NSString stringWithFormat:@"%@",model.praisecount];
    self.covewImageView.layer.masksToBounds = YES;
    self.covewImageView.layer.cornerRadius = self.covewImageView.frame.size.width/2.0;
    self.countLabel.text = model.model.name;
    self.viewTimeLabel.text = model.model.timestr;
    if (self.model.ispraise.integerValue == 1) {
        self.likeBtn.selected = YES;
        self.likeCountLabel.textColor = [UIColor redColor];
    }else{
         self.likeBtn.selected = NO;
         self.likeCountLabel.textColor = [UIColor colorWithHexString:@"AFB6C1"];
    }
    if (model.model.name.length <= 0) {
        self.activityPushView.hidden = YES;
    }
    
}
- (IBAction)likeBtnAction:(UIButton *)sender {
    if ([self.activityAboutreadCellDelegate respondsToSelector:@selector(likeTapActionBtn)]) {
        [self.activityAboutreadCellDelegate likeTapActionBtn];
    }
    
}
- (void)searchTag:(UITapGestureRecognizer *)g{
    NSInteger index = g.view.tag;
    if ([self.activityAboutreadCellDelegate respondsToSelector:@selector(searchTagActovity:)]) {
        [self.activityAboutreadCellDelegate searchTagActovity:index];
    }
    
}
- (IBAction)gotoAboutActivity:(UITapGestureRecognizer *)sender {
    ActivityDetailController *detail = [[ActivityDetailController alloc]init];
    detail.activityid = self.model.model.activityid;
    [[self viewController].navigationController pushViewController:detail animated:YES];
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
