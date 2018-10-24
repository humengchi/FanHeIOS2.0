//
//  CardListCell.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/16.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "CardListCell.h"
#import "ChatViewController.h"
#import "NewAddFriendController.h"
#import "ShareNormalView.h"
#import "ChoiceFriendViewController.h"

@interface CardListCell ()

@property (nonatomic, weak) IBOutlet UIImageView *cardImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *companyLabel;
@property (nonatomic, weak) IBOutlet UILabel *positionLabel;
@property (nonatomic, weak) IBOutlet UIButton *choiseBtn;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *btnLayoutConstraint;

@property (nonatomic, strong) CardScanModel *model;

@end

@implementation CardListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [CALayer updateControlLayer:self.cardImageView.layer radius:2 borderWidth:0.5 borderColor:HEX_COLOR(@"afb6c1").CGColor];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateDisplayIsChatRoom:(CardScanModel*)model{
    [self updateDisplay:model];
    self.choiseBtn.hidden = YES;
}

- (void)updateDisplay:(CardScanModel*)model{
    self.model = model;
    [self.cardImageView sd_setImageWithURL:[NSURL URLWithString:model.imgurl] placeholderImage:kImageWithName(@"mr_mp_mptu")];
    self.btnLayoutConstraint.constant = 66;
    [self.choiseBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    if(model.ismycard.integerValue==1){
        self.nameLabel.text = model.name.length?model.name:[DataModelInstance shareInstance].userModel.realname;
        self.companyLabel.text = @"我的名片";
        self.positionLabel.text = @"";
        if(model.cardId.integerValue){
            [self.choiseBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
            [self.choiseBtn setImage:kImageWithName(@"btn_dt_zf") forState:UIControlStateNormal];
            [self.choiseBtn setBackgroundImage:nil forState:UIControlStateNormal];
            [self.choiseBtn setTitle:@"" forState:UIControlStateNormal];
        }else{
            self.btnLayoutConstraint.constant = 0;
            self.companyLabel.text = @"还未扫描自己的名片，点击扫描";
        }
    }else if(model.ismycard.integerValue==0){
        self.nameLabel.text = model.name;
        if(model.company.count){
            self.companyLabel.text = model.company[0];
        }
        if(model.position.count){
            self.positionLabel.text = model.position[0];
        }
        [self.choiseBtn setImage:nil forState:UIControlStateNormal];
        [self.choiseBtn setBackgroundImage:kImageWithName(@"btn_bg_red") forState:UIControlStateNormal];
        if(model.btn.integerValue==1){
            [self.choiseBtn setTitle:@"邀请好友" forState:UIControlStateNormal];
        }else if(model.btn.integerValue==2){
            [self.choiseBtn setTitle:@"添加好友" forState:UIControlStateNormal];
        }else{
            [self.choiseBtn setTitle:@"发消息" forState:UIControlStateNormal];
        }
    }else{
        self.btnLayoutConstraint.constant = 0;
        self.nameLabel.text = @"扫描第一张名片";
        self.companyLabel.text = @"智能识别，名片管理";
        self.positionLabel.text = @"";
        self.cardImageView.image = kImageWithName(@"mr_mp_saomiao");
    }
}

- (IBAction)buttonClicked:(UIButton*)sender{
    if(self.model.ismycard.integerValue==1){
        if(self.model.cardId.integerValue){
            ShareNormalView *shareView = [CommonMethod getViewFromNib:@"ShareNormalViewFour"];
            shareView.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
            @weakify(self);
            shareView.shareIndex = ^(NSInteger index){
                @strongify(self);
                if (index == 2) {
                    ChoiceFriendViewController *choseCtr = [CommonMethod getVCFromNib:[ChoiceFriendViewController class]];
                    choseCtr.cardModel = self.model;
                    [[self viewController].navigationController pushViewController:choseCtr animated:YES];
                }else if(index==3){
                    UIPasteboard *paste = [UIPasteboard generalPasteboard];
                    [paste setString:[NSString stringWithFormat:@"%@/%@",ShareCardUrl, self.model.cardId]];
                    [MBProgressHUD showSuccess:@"复制成功" toView:[self viewController].view];
                }else{
                    [self firendClickWX:index];
                }
            };
            [[UIApplication sharedApplication].keyWindow addSubview:shareView];
            [shareView showShareNormalView];
        }
    }else if(self.model.ismycard.integerValue==0){
        if(self.model.btn.integerValue==1){
            NSString *title = [NSString stringWithFormat:@"我正在使用“3号圈”拓展金融人脉！推荐你来看看【%@】", DownloadUrl];
            [((BaseViewController*)self.viewController) showMessageView:@[self.model.phone] title:title];
        }else if(self.model.btn.integerValue==2){
            NewAddFriendController *vc = [[NewAddFriendController alloc] init];
            vc.userID = self.model.otherid;
            vc.realname = self.model.name;
            [[self viewController].navigationController pushViewController:vc animated:YES];
        }else{
            NSString *chartId = [NSString stringWithFormat:@"%@",self.model.otherid];
            ChatViewController *chatVC = [[ChatViewController alloc]initWithConversationChatter:chartId conversationType:EMConversationTypeChat];
            chatVC.title = self.model.name;
            NSMutableString *str = [NSMutableString string];
            if(self.model.company.count){
                [str appendString:self.model.company.firstObject];
            }
            if(self.model.position.count){
                [str appendString:self.model.position.firstObject];
            }
            chatVC.position = str;
            chatVC.phoneNumber = self.model.phone;
            chatVC.pushIndex = 888;
            [[self viewController].navigationController pushViewController:chatVC animated:YES];
        }
    }
}

#pragma mark ----------分享 ---
- (void)firendClickWX:(NSInteger)index{
    NSString *title = [NSString stringWithFormat:@"%@的名片", self.model.name];
    NSMutableString *content = [NSMutableString string];
    if(self.model.company.count){
        [content appendString:self.model.company.firstObject];
        [content appendString:@" "];
    }
    if(self.model.company.count){
        [content appendString:self.model.position.firstObject];
    }
    UIImage *imageSource = kImageWithName(@"icon-60");
    
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    UMSocialPlatformType shareType;
    if (index == 0) {
        shareType = UMSocialPlatformType_WechatSession;
    }else{
        shareType = UMSocialPlatformType_WechatTimeLine;
    }
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:content thumImage:imageSource];
    shareObject.webpageUrl = [NSString stringWithFormat:@"%@/%@",ShareCardUrl, self.model.cardId];
    messageObject.shareObject = shareObject;
    [[UMSocialManager defaultManager] shareToPlatform:shareType messageObject:messageObject currentViewController:[self viewController] completion:^(id data, NSError *error) {
    }];
}

- (void)layoutSubviews{
    for (UIView *subView in self.subviews) {
        if([subView isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")]) {
            if(subView.subviews.count<4){
                break;
            }
            NSArray *array = @[@"icon_mp_dete",@"icon_mp_fz",@"icon_mp_tele",@"icon_mp_message"];
            for(int i=0; i<4; i++){
                UIView *btnView = subView.subviews[i];
                btnView.backgroundColor = HEX_COLOR(@"afb6c1");
                for (UIView *btn in btnView.subviews) {
                    UIImageView *imageview = [[UIImageView alloc] init];
                    imageview.contentMode = UIViewContentModeScaleAspectFit;
                    imageview.image = kImageWithName(array[i]);
                    imageview.frame = CGRectMake(0, 0, btn.frame.size.width, btn.frame.size.height);
                    [btn addSubview:imageview];
                }
            }
        }
    }
}

@end
