//
//  MyStartCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/20.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "MyStartCell.h"
#import "TopicViewController.h"
#import "InformationDetailController.h"
#import "ViewpointDetailViewController.h"
#import "RateDetailController.h"
@implementation MyStartCell
- (void)tranferMyStartCellMyTopicModel:(MyTopicModel *)model{
    self.topModel = model;
    
    if (model.realname.length <= 0) {
        self.titleLAbel.text =  [model.content filterHTML];
    }else{
        self.titleLAbel.attributedText = [self tranferStr:[NSString stringWithFormat:@"回复 %@ %@",model.realname,[model.content filterHTML]] name:model.realname];
        self.rateLabel.hidden = YES;
    }

    self.titleLAbel.userInteractionEnabled = YES;
    self.likeLabel.text = [NSString stringWithFormat:@"赞 %@",model.mypraisecount];
    self.rateLabel.text = [NSString stringWithFormat:@"评论 %@",model.myreviewcount];
    self.timeLabel.text = model.createtime;
    if (model.type.integerValue == 1) {
        self.coverImageView.image = kImageWithName(@"icon_mytopic_topic");
    }else{
       self.coverImageView.image = kImageWithName(@"icon_mytopic_zixun");
    }
    
     self.viewtitleLabel.text = model.title;
 
    self.attionLabel.text = [NSString stringWithFormat:@"关注 %@",model.attentcount];
    self.viewPointLabel.text = [NSString stringWithFormat:@"观点 %@",model.replycount];
    self.viewRateLabel.text = [NSString stringWithFormat:@"评论 %@",model.reviewcount];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
+ (CGFloat)backMyStartCellHeigthMyTopicModel:(MyTopicModel *)model {
    CGFloat heigt2 = [NSHelper heightOfString:[model.content filterHTML] font:[UIFont systemFontOfSize:14] width:WIDTH - 32];
    if (heigt2 > 70) {
        heigt2 = 68;
    }
    return 151 + heigt2 - 14;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)topOrInforDetailActtion:(UITapGestureRecognizer *)sender {
    if (self.topModel.type.integerValue == 1) {
        TopicViewController *vc = [CommonMethod getVCFromNib:[TopicViewController class]];
        vc.subjectId = self.topModel.gid;//@(628);//53
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }else{
        InformationDetailController  *intDetailCtr = [[InformationDetailController alloc]init];
        intDetailCtr.postID = self.topModel.gid;
        intDetailCtr.startType = YES;
        [[self viewController].navigationController pushViewController:intDetailCtr animated:YES];
       
    }
}

- (IBAction)messageOrTopicAtion:(UITapGestureRecognizer *)sender {
    if (self.topModel.type.integerValue == 1) {
        //观点详情
        ViewpointDetailViewController *vc = [CommonMethod getVCFromNib:[ViewpointDetailViewController class]];
        vc.viewpointId = self.topModel.reviewid;//@(628);//53
        TopicDetailModel *topicDetailModel = [[TopicDetailModel alloc] init];
        topicDetailModel.subjectid = self.topModel.subjectid;
        topicDetailModel.title = self.topModel.title;
        vc.topicDetailModel = topicDetailModel;
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }else{
        //资讯一级评论
        
        RateDetailController *vc = [CommonMethod getVCFromNib:[RateDetailController class]];
        vc.reviewid = self.topModel.reviewid;;//@(628);//53
    [[self viewController].navigationController pushViewController:vc animated:YES];
        
    }
    

}
- (NSMutableAttributedString *)tranferStr:(NSString *)str name:(NSString *)name{
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:str];
           [AttributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"F76B1C"] range:NSMakeRange(0, name.length + 3)];
      return AttributedStr;
}
@end
