//
//  MyHomeTopicCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/22.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "MyHomeTopicCell.h"
#import "ViewpointDetailViewController.h"
#import "TopicViewController.h"
#import "MyViewpointController.h"
@implementation MyHomeTopicCell
- (void)tranferMyHomeTopicCellMyTopicModel:(MyTopicModel *)model{
    self.topModel = model;
    
    self.countTextView.userInteractionEnabled = YES;
    self.countTextView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    self.countTextView.editable = NO;
    self.countTextView.scrollEnabled = NO;
    [self.countTextView setTextContainerInset:UIEdgeInsetsZero];
    self.countTextView.textContainer.lineFragmentPadding = 0;
    self.countTextView.attributedText = [NSHelper contentStringFromRawString:model.content];

   
    self.likeLabel.text = [NSString stringWithFormat:@"赞 %@",model.srpraisecount ];
    self.rateLabel.text = [NSString stringWithFormat:@"评论 %@",model.srreviewcount ];
    self.timeLabel.text = model.created_at;
    
    
     CGFloat heigth = [NSHelper heightOfString:[model.title filterHTML] font:[UIFont systemFontOfSize:14] width:WIDTH - 68 - 28];
//    CGFloat heigth = [NSHelper heightOfString:[model.content filterHTML] font:[UIFont systemFontOfSize:14] width:WIDTH - 68 - 28];
    
    CGFloat x = 0;
    if (heigth > 18) {
        heigth = 28;
        x = 12;
    }else{
        x = 23;
        heigth = 16;
    }
    self.viewtitleLabel.frame = CGRectMake(52, x, WIDTH - 68 - 28, heigth);
 
    self.viewtitleLabel.text =  [model.title filterHTML];
    self.attionLabel.text = [NSString stringWithFormat:@"关注 %@",model.sattentcount];
    self.viewPointLabel.text = [NSString stringWithFormat:@"观点 %@",model.sreplycount];
    self.viewRateLabel.text = [NSString stringWithFormat:@"评论 %@",model.sreviewcount];
}
+ (CGFloat)backMyHomeTopicCellHeigthMyTopicModel:(MyTopicModel *)model{
    CGFloat heigt2 = [NSHelper heightOfString:[model.content filterHTML] font:[UIFont systemFontOfSize:14] width:WIDTH - 32];
    if (heigt2 > 70) {
        heigt2 = 68;
    }
    return 228 + heigt2;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)informationDetail:(UITapGestureRecognizer *)sender {
    TopicViewController *vc = [CommonMethod getVCFromNib:[TopicViewController class]];
    vc.subjectId = self.topModel.sid;//@(628);//53
    [[self viewController].navigationController pushViewController:vc animated:YES];
}

- (IBAction)topicDetail:(UITapGestureRecognizer *)sender {
    ViewpointDetailViewController  *intDetailCtr = [[ViewpointDetailViewController alloc]init];
    intDetailCtr.viewpointId = self.topModel.srid;
    TopicDetailModel *topicDetailModel = [[TopicDetailModel alloc] init];
    topicDetailModel.subjectid = self.topModel.subjectid;
    topicDetailModel.title = self.topModel.title;
    intDetailCtr.topicDetailModel = topicDetailModel;
    [[self viewController].navigationController pushViewController:intDetailCtr animated:YES];
}
- (IBAction)checkMoreTopic:(UIButton *)sender {
    MyViewpointController *vc = [[MyViewpointController alloc]init];;
    vc.userID = self.userID;
    [[self viewController].navigationController pushViewController:vc animated:YES];
}

@end
