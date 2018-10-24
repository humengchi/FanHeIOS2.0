//
//  NotificationReviewCell.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/4/17.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "NotificationReviewCell.h"
#import "InformationDetailController.h"
#import "TopicViewController.h"
#import "ViewpointDetailViewController.h"
#import "RateDetailController.h"

@interface NotificationReviewCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *userTypeImageView;
@property (weak, nonatomic) IBOutlet UILabel *cntentLabel;

@property (weak, nonatomic) IBOutlet UIImageView *typeImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *ryhDelectLabel;

@property (nonatomic ,strong) MyTopicModel *model;

@end

@implementation NotificationReviewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.headerImageView.layer.cornerRadius = self.headerImageView.frame.size.width/2.0;
    self.headerImageView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)createrNotificationCellNotificationCell:(MyTopicModel *)model{
    self.model = model;
    
    self.headerImageView.layer.cornerRadius = self.headerImageView.frame.size.width/2.0;
    self.headerImageView.layer.masksToBounds = YES;
    if (model.ishidden.integerValue == 1) {
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(@"匿名")];
        self.nameLabel.userInteractionEnabled = NO;
        self.headerImageView.userInteractionEnabled = NO;
        
    }else{
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(@"model.realname")];
        self.nameLabel.userInteractionEnabled = YES;
        self.headerImageView.userInteractionEnabled = YES;
    }
    self.nameLabel.text = model.realname;
    self.userTypeImageView.hidden = model.usertype.integerValue!=9;
    
    if (self.model.status.integerValue == 1) {
        self.typeImageView.image = kImageWithName(@"icon_mytopic_zixun");
        self.ryhDelectLabel.text = @"该资讯被删除";
    }else{
        self.typeImageView.image = kImageWithName(@"icon_mytopic_topic");
        self.ryhDelectLabel.text = @"该话题被删除";
    }
    self.typeLabel.text = model.content;
    self.timeLabel.text = model.created_at;
    self.cntentLabel.attributedText = [NSHelper contentStringFromRawString:model.mycontent];//model.mycontent;
    
    self.countLabel.text = [NSString stringWithFormat:@"关注 %@  观点 %@  评论 %@",model.model.attentcount, model.model.replycount, model.model.reviewcount];
    
    if (model.model.gid.integerValue == 0) {
        self.ryhDelectLabel.hidden = NO;
        self.titleLabel.hidden = YES;
        self.countLabel.hidden = YES;
    }else{
        self.ryhDelectLabel.hidden = YES;
        self.titleLabel.hidden = NO;
        self.countLabel.hidden = NO;
        self.titleLabel.text = model.model.title;
    }
}

- (IBAction)gotoHisPag:(UITapGestureRecognizer *)sender {
    NewMyHomePageController *myHome = [[NewMyHomePageController alloc]init];
    myHome.userId = self.model.userid;
//    myHome.stayTapy = YES;
    [[self viewController].navigationController pushViewController:myHome animated:YES];
}

- (IBAction)gotoDiscussDetail:(UITapGestureRecognizer *)sender {
    if(self.model.type.integerValue == 8){
        ViewpointDetailViewController *vc = [CommonMethod getVCFromNib:[ViewpointDetailViewController class]];
        vc.viewpointId = self.model.subject_review_id;
        TopicDetailModel *topicDetailModel = [[TopicDetailModel alloc] init];
        topicDetailModel.subjectid = self.model.subject_review_id;
        topicDetailModel.title = self.model.title;
        vc.topicDetailModel = topicDetailModel;
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }else{
        RateDetailController *vc = [CommonMethod getVCFromNib:[RateDetailController class]];
        vc.reviewid = self.model.review_id;
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)gotomessageOrTopic:(UITapGestureRecognizer *)sender {
    if (self.model.isViewPoint == YES) {
        if (self.model.type.integerValue == 2) {
            InformationDetailController  *intDetailCtr = [[InformationDetailController alloc]init];
            intDetailCtr.postID = self.model.model.gid;
            intDetailCtr.startType = YES;
            [[self viewController].navigationController pushViewController:intDetailCtr animated:YES];
        }else{
            TopicViewController *vc = [CommonMethod getVCFromNib:[TopicViewController class]];
            vc.subjectId = self.model.model.gid;//@(628);//53
            [[self viewController].navigationController pushViewController:vc animated:YES];
        }
    }else{
        if ((self.model.type.integerValue == 2 ||self.model.type.integerValue == 3)&& self.model.status.integerValue == 1) {
            InformationDetailController  *intDetailCtr = [[InformationDetailController alloc]init];
            intDetailCtr.postID = self.model.model.gid;
            intDetailCtr.startType = YES;
            [[self viewController].navigationController pushViewController:intDetailCtr animated:YES];
        }else{
            TopicViewController *vc = [CommonMethod getVCFromNib:[TopicViewController class]];
            vc.subjectId = self.model.model.gid;//@(628);//53
            [[self viewController].navigationController pushViewController:vc animated:YES];
        }
    }
}

@end
