//
//  NotificationCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/21.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "NotificationCell.h"
#import "InformationDetailController.h"
#import "TopicViewController.h"
@interface NotificationCell ()<UITextViewDelegate>
@end

@implementation NotificationCell
- (void)createrNotificationCellNotificationCell:(MyTopicModel *)model{
    self.model = model;
    
    self.userTypeImageView.hidden = model.usertype.integerValue!=9;
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
    if (model.status.integerValue == 1) {
        if (model.type.integerValue == 2) {
            self.atmessageLabel.text = @"发表了评论:";
        }else if (model.type.integerValue == 3){
            self.atmessageLabel.text = @"回复了你:";
        }else if (model.type.integerValue == 4){
            self.atmessageLabel.text = @"邀请你参与讨论:";
        }else{
            self.atmessageLabel.text = @"回复了你:";
        }
    }else if (model.status.integerValue == 3){
        self.atmessageLabel.text = @"提到了你:";
        
    }
    if ((self.model.type.integerValue == 2 ||self.model.type.integerValue == 3)&& self.model.status.integerValue == 1) {
        self.typeImage.image = kImageWithName(@"icon_mytopic_zixun");
        
    }else{
        self.typeImage.image =   kImageWithName(@"icon_mytopic_topic");
    }
    
    self.titleTextView.userInteractionEnabled = YES;
    self.titleTextView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleTextView.editable = NO;
    self.titleTextView.scrollEnabled = NO;
    [self.titleTextView setTextContainerInset:UIEdgeInsetsZero];
    self.titleTextView.textContainer.lineFragmentPadding = 0;
    
    self.titleTextView.delegate = self;
    self.titleTextView.attributedText = [NSHelper contentStringFromRawString:model.content];
    
    self.timeLabel.text = model.created_at;
    
    [self.titleTextView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(forwardingEvent:)]];
    UILongPressGestureRecognizer *longRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(addGestureRecognizer:)];
    [self.titleTextView addGestureRecognizer:longRecognizer];
    self.attionlabel.text = [NSString stringWithFormat:@"关注 %@",model.model.attentcount];
    self.viewpointLabel.text = [NSString stringWithFormat:@"观点 %@",model.model.replycount];
    self.rateLabel.text = [NSString stringWithFormat:@"评论 %@",model.model.reviewcount];
      
    if (model.model.gid.integerValue == 0) {
        if (model.type.integerValue == 2||model.type.integerValue == 3) {
              self.ryhDelectLabel.text = @"该资讯被删除";
        }
        if (model.type.integerValue == 4 || model.type.integerValue == 8) {
            self.ryhDelectLabel.text = @"该话题被删除";
        }
        self.attionlabel.hidden = YES;
        self.viewpointLabel.hidden = YES;
        self.rateLabel.hidden = YES;
        self.countLabel.hidden = YES;

    }else{
         self.countLabel.text = model.model.title;
        self.ryhDelectLabel.hidden = YES;
    }
}
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    
    //    UITextView *text=(UITextView *)sender;
    [UIMenuController sharedMenuController].menuVisible = NO;  //donot display the menu
    [self.titleTextView resignFirstResponder];                     //do not allow the user to selected anything
    return NO;
    
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
}
- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    //Prevent zooming but not panning
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
    {
        gestureRecognizer.enabled = NO;
    }
    [super addGestureRecognizer:gestureRecognizer];
}
- (void)forwardingEvent:(UITapGestureRecognizer* )tap{
    if ([self.notificationCellDelegate respondsToSelector:@selector(textViewTouchPointProcessing:)]) {
        [self.notificationCellDelegate textViewTouchPointProcessing:tap];
    }
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
+ (CGFloat)backNotificationCellMyTopicModel:(MyTopicModel *)model{
    CGFloat heigth1 = [NSHelper rectHeightWithStr:model.content];
    if (heigth1 > 0) {
        heigth1 =  heigth1 + 12;
    }
    return heigth1 + 185 - 12-6;
}
#pragma mark --- UITextView delegate
-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    NSString *symbolsStr = [URL absoluteString];
    if([symbolsStr hasPrefix:NotificationURL]){
        symbolsStr = [symbolsStr substringFromIndex:[NotificationURL length]];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *numTemp = [numberFormatter numberFromString:symbolsStr];
        NewMyHomePageController *myHome = [[NewMyHomePageController alloc]init];
        myHome.userId = numTemp;
//        myHome.stayTapy = YES;
        [[self viewController].navigationController pushViewController:myHome animated:YES];
    }
    return NO;
}

- (IBAction)gotoHisPag:(UITapGestureRecognizer *)sender {
    NewMyHomePageController *myHome = [[NewMyHomePageController alloc]init];
    myHome.userId = self.model.userid;
//    myHome.stayTapy = YES;
    [[self viewController].navigationController pushViewController:myHome animated:YES];
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

- (IBAction)gotoHisMainPage:(UITapGestureRecognizer *)sender {
    NewMyHomePageController *myHome = [[NewMyHomePageController alloc]init];
    myHome.userId = self.model.userid;
//    myHome.stayTapy = YES;
    [[self viewController].navigationController pushViewController:myHome animated:YES];
}

@end
