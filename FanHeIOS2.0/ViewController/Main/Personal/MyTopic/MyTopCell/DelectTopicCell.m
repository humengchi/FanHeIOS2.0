//
//  DelectTopicCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/21.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "DelectTopicCell.h"
#import "TopicViewController.h"
#import "InformationDetailController.h"
@implementation DelectTopicCell
- (void)tranferDelectTopicCellMyTopicModel:(MyTopicModel *)model uiseID:(NSNumber *)uid{
    self.topModel = model;
        self.titleLAbel.text = model.title;
    self.likeLabel.text = [NSString stringWithFormat:@"赞 %@",model.mypraisecount];
    self.rateLabel.text = [NSString stringWithFormat:@"评论 %@",model.myreviewcount];
    self.timeLabel.text = model.createtime;
    if (model.type.integerValue == 1) {
        self.coverImageView.image = kImageWithName(@"icon_mytopic_topic");
        self.countLabel.text = @"该话题已被删除";
    }else{
       
        self.coverImageView.image = kImageWithName(@"icon_mytopic_zixun");
        self.countLabel.text = @"该资讯已被删除";
    }
    
   
}
+ (CGFloat)backDelectTopicCellHeigthMyTopicModel:(MyTopicModel *)model{
    CGFloat heigt2 = [NSHelper heightOfString:model.title font:[UIFont systemFontOfSize:14] width:WIDTH - 32];
    if (heigt2 > 70) {
        heigt2 = 68;
    }
    return 130 + heigt2;

}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)gotoTopicOrMessage:(UITapGestureRecognizer *)sender {
    if (self.topModel.type.integerValue == 1) {
        [MBProgressHUD showError:@"该话题已被删除" toView:self];
    }else{
          [MBProgressHUD showError:@"该资讯已被删除" toView:self];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
