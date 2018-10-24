//
//  ViewpointDetailTableViewCell.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/15.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ViewpointDetailTableViewCell.h"
#import "RichTextViewController.h"
#import "TopicIdentifyViewController.h"
#import "ReportViewController.h"

@interface ViewpointDetailTableViewCell ()

@property (nonatomic, weak) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *vipImageView;
@property (weak, nonatomic) IBOutlet UILabel *noNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *realNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *zfImageView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *praiseBtn;
@property (weak, nonatomic) IBOutlet UIButton *replyBtn;
@property (weak, nonatomic) IBOutlet UILabel *replyUserLabel;


@property (nonatomic, strong) UIMenuController *menu;
@property (nonatomic, strong) ReviewModel *model;

@end

@implementation ViewpointDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [CALayer updateControlLayer:self.headerImageView.layer radius:22 borderWidth:0 borderColor:nil];
    [CommonMethod viewAddGuestureRecognizer:self.replyUserLabel tapsNumber:1 withTarget:self withSEL:@selector(gotoReplyUserHomePage)];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    [self.menu setMenuVisible:NO animated:YES];
    // Configure the view for the selected state
}

- (void)gotoReplyUserHomePage{
    if([CommonMethod paramNumberIsNull:self.model.replyto[@"userid"]].integerValue){
        NewMyHomePageController *vc = [[NewMyHomePageController alloc] init];
        vc.userId = [CommonMethod paramNumberIsNull:self.model.replyto[@"userid"]];
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)gotoHomePageClicked:(id)sender{
    if(self.model.ishidden.integerValue == 0){
        NewMyHomePageController *vc = [[NewMyHomePageController alloc] init];
        vc.userId = self.model.userid;
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)praiseClicked:(UIButton*)sender{
    [[self viewController] newThreadForAvoidButtonRepeatClick:sender];
    if(self.model.ispraise.integerValue == 1){
        [self showToastMessage:@"你已经点过赞啦"];
    }else{
        [self praiseHttpData];
    }
}

#pragma mark -点赞
- (void)praiseHttpData{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.model.reviewid forKey:@"reviewid"];
    [[[UIViewController alloc] init] requstType:RequestType_Post apiName:API_NAME_POST_PRAISE_SUBREVIEW paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if(weakSelf.model.ispraise.integerValue==0){
                weakSelf.model.ispraise = @(1);
                weakSelf.model.praisecount = @(self.model.praisecount.integerValue+1);
                [weakSelf.praiseBtn setTitle:[NSString stringWithFormat:@" %@",[NSString getNumStr:self.model.praisecount]] forState:UIControlStateNormal];
                [weakSelf.praiseBtn setImage:kImageWithName(@"icon_dianzan_yidian") forState:UIControlStateNormal];
                [weakSelf.praiseBtn setTitleColor:HEX_COLOR(@"E24943") forState:UIControlStateNormal];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

- (IBAction)replyReviewClicked:(id)sender{
    [[self viewController] newThreadForAvoidButtonRepeatClick:sender];
    if(self.model.userid.integerValue == [DataModelInstance shareInstance].userModel.userId.integerValue){
        __weak typeof(self) weakSelf = self;
        [[[CommonUIAlert alloc] init] showCommonAlertView:[self viewController] title:@"" message:@"是否要删除该条评论？" cancelButtonTitle:@"取消" otherButtonTitle:@"确认" cancle:^{
            
        } confirm:^{
            [weakSelf deleteReviewHttp];
        }];
    }else{
        if([DataModelInstance shareInstance].userModel.hasValidUser.integerValue == 1){
            RichTextViewController *vc = [[RichTextViewController alloc] init];
            vc.commentType = 2;//回复
            vc.replyName = self.model.realname;
            vc.reviewId = self.model.reviewid;
            vc.replyMessageSuccess = ^(){
                if(self.replyReviewSuccess){
                    self.replyReviewSuccess();
                }
            };
            [[self viewController] presentViewController:vc animated:YES completion:nil];
        }else{
            TopicIdentifyViewController *vc = [CommonMethod getVCFromNib:[TopicIdentifyViewController class]];
            vc.publishType = PublishType_Review;
            [[self viewController].navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - 删除评论
- (void)deleteReviewHttp{
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"删除评论..." toView:[self viewController].view];
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@", self.model.reviewid,[DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [[[UIViewController alloc] init] requstType:RequestType_Delete apiName:API_NAME_POST_DEL_SUB_REVIEW paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"删除成功" toView:[weakSelf viewController].view];
            if(weakSelf.deleteReviewSuccess){
                weakSelf.deleteReviewSuccess(weakSelf);
            }
        }else{
            [MBProgressHUD showError:@"删除失败" toView:[weakSelf viewController].view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"无法连接到网络" toView:[weakSelf viewController].view];
    }];
}

- (void)updateDisplay:(ReviewModel*)model vpdModel:(ViewpointDetailModel*)vpdModel{
    if(vpdModel.mergeto.integerValue){
        self.replyBtn.userInteractionEnabled = NO;
        self.praiseBtn.userInteractionEnabled = NO;
    }
    if(model.replyto&&model.replyto.allKeys.count){
        NSString *text = [NSString stringWithFormat:@"回复 %@", model.replyto[@"realname"]];
        NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:text];
        [atr setAttributes:@{NSFontAttributeName:FONT_SYSTEM_SIZE(14), NSForegroundColorAttributeName:HEX_COLOR(@"4393e2")} range:NSMakeRange(3, text.length-3)];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        [paragraphStyle setLineSpacing:6];
        [atr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, text.length)];
        self.replyUserLabel.attributedText = atr;
    }else{
        self.replyUserLabel.text = @"";
    }
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
    longPress.minimumPressDuration = 0.5;
    self.contentLabel.userInteractionEnabled = YES;
    [self.contentLabel addGestureRecognizer:longPress];
    self.model = model;
    self.vipImageView.hidden = model.usertype.integerValue != 9;
    if(model.ishidden.integerValue == 1){
        self.headerImageView.image = KHeadImageDefaultName(@"匿名");
        self.noNameLabel.hidden = NO;
    }else{
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
        self.noNameLabel.hidden = YES;
        self.realNameLabel.text = model.realname;
        self.companyLabel.text = [NSString stringWithFormat:@"%@%@",model.company, model.position];
    }
    self.zfImageView.hidden = model.othericon.integerValue !=1;
    [self.contentLabel setParagraphText:model.content lineSpace:6];
    
    self.timeLabel.text = model.created_at;
    if(model.userid.integerValue == [DataModelInstance shareInstance].userModel.userId.integerValue){
        [self.replyBtn setSelected:YES];
    }else{
        [self.replyBtn setSelected:NO];
    }
    if(model.praisecount.integerValue){
        [self.praiseBtn setTitle:[NSString stringWithFormat:@" %@",[NSString getNumStr:model.praisecount]] forState:UIControlStateNormal];
    }
    if(model.ispraise.integerValue){
        [self.praiseBtn setImage:kImageWithName(@"icon_dianzan_yidian") forState:UIControlStateNormal];
        [self.praiseBtn setTitleColor:HEX_COLOR(@"E24943") forState:UIControlStateNormal];
    }
}

- (void)longPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        if(self.menu==nil){
            self.menu = [UIMenuController sharedMenuController];
            UIMenuItem *copy = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyMenuAction)];
            UIMenuItem *report = [[UIMenuItem alloc] initWithTitle:@"举报" action:@selector(reportMenuAction)];
            if(self.model.userid.integerValue == [DataModelInstance shareInstance].userModel.userId.integerValue){
                [self.menu setMenuItems:[NSArray arrayWithObjects:copy,nil]];
            }else{
                [self.menu setMenuItems:[NSArray arrayWithObjects:copy, report, nil]];
            }
        }
        [self.menu setTargetRect:self.contentLabel.frame inView:self.contentLabel.superview];
        [self.menu setMenuVisible:YES animated:YES];
    }
}

- (void)copyMenuAction{
    UIPasteboard *generalPasteBoard = [UIPasteboard generalPasteboard];
    [generalPasteBoard setString:self.model.content];
    [MBProgressHUD showSuccess:@"复制成功" toView:[self viewController].view];
}

- (void)reportMenuAction{
    ReportViewController *vc = [CommonMethod getVCFromNib:[ReportViewController class]];
    vc.reportType = ReportType_Review;
    vc.reportId = self.model.reviewid;
    [[self viewController].navigationController pushViewController:vc animated:YES];
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action ==@selector(copyMenuAction) || action ==@selector(reportMenuAction)){
        return YES;
        
    }
    return NO;//隐藏系统默认的菜单项
}


@end
