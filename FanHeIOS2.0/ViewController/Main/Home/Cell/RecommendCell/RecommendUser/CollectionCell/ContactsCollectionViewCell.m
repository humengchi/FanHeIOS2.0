//
//  ContactsCollectionViewCell.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/10/25.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ContactsCollectionViewCell.h"
#import "EditPersonalInfoViewController.h"
#import "NewAddFriendController.h"

@interface ContactsCollectionViewCell ()

@property (nonatomic, weak) IBOutlet UIImageView *headerImageView;
@property (nonatomic, weak) IBOutlet UIImageView *identifyImageView;
@property (nonatomic, weak) IBOutlet UIImageView *vipImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *companyLabel;
@property (nonatomic, weak) IBOutlet UILabel *positonLabel;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIButton *addFriendBtn;

@property (nonatomic, strong) UserModel *model;

@end

@implementation ContactsCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        //initialize code...
    }
    return self;
}

- (void)updateDisplayUserModelIntroduce:(UserModel*)model{
    [CALayer updateControlLayer:self.headerImageView.layer radius:60*WIDTH/375.0/2 borderWidth:0 borderColor:nil];
    self.identifyImageView.hidden = model.hasValidUser.integerValue!=1;
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
    self.nameLabel.text = [CommonMethod paramStringIsNull:model.realname];
    self.companyLabel.text = [CommonMethod paramStringIsNull:model.company];
    self.positonLabel.text = [CommonMethod paramStringIsNull:model.position];
    self.vipImageView.hidden = model.usertype.integerValue != 9;
    self.nameLabel.hidden = NO;
    self.positonLabel.hidden = NO;
}

- (void)updateDisplayUserModel:(UserModel*)model{
    self.model = model;
    [CALayer updateControlLayer:self.headerImageView.layer radius:27 borderWidth:0 borderColor:nil];
    if(model == nil){
        self.identifyImageView.hidden = YES;
        self.vipImageView.hidden = YES;
        self.nameLabel.hidden = YES;
        self.positonLabel.hidden = YES;
        self.companyLabel.text = @"更多人脉推荐";
        self.companyLabel.textAlignment = NSTextAlignmentCenter;
        self.companyLabel.textColor = HEX_COLOR(@"818c9e");
        self.headerImageView.image = kImageWithName(@"bg_index_more");
    }else{
        self.companyLabel.textAlignment = NSTextAlignmentCenter;
        self.companyLabel.textColor = HEX_COLOR(@"41464e");
        self.identifyImageView.hidden = model.hasValidUser.integerValue!=1;
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[CommonMethod paramStringIsNull:model.realname]];
            if(model.usertype.integerValue == 9){
                NSTextAttachment *textAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil] ;
                textAttachment.image = [UIImage imageNamed:@"icon_v_jv"];
                textAttachment.bounds = CGRectMake(2, -3, 16, 16);
                NSAttributedString *textAttachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment] ;
                [attr appendAttributedString:textAttachmentString];
                self.nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
            }else{
                self.nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.nameLabel.attributedText = attr;
                self.nameLabel.hidden = NO;
            });
        });
        
        self.companyLabel.text = [CommonMethod paramStringIsNull:model.company];
        self.positonLabel.text = [CommonMethod paramStringIsNull:model.position];
        self.positonLabel.hidden = NO;
    }
    //0.加好友 1.已发送 2.正在发送
    self.addFriendBtn.hidden = model.invite.integerValue==2;
    self.addFriendBtn.enabled = model.invite.integerValue==0;
    self.activityIndicatorView.hidden = model.invite.integerValue!=2;
    if(model.invite.integerValue==2){
        [self.activityIndicatorView startAnimating];
    }else{
        [self.activityIndicatorView stopAnimating];
    }
}

- (void)updateDisplayDJTalkModel:(DJTalkModel*)model{
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KWidthImageDefault];
    self.nameLabel.text = model.title;;
}

- (IBAction)deleteButtonClicked:(UIButton*)sender{
    if(self.deleteCell){
        self.deleteCell(self);
    }
}

- (IBAction)addFriendButtonClicked:(UIButton*)sender{
    if(![CommonMethod getUserCanAddFriend]){
        CompleteUserInfoView *completeUserInfoView = [[CompleteUserInfoView alloc] initWithType:CompleteUserInfoViewType_AddFriend];
        completeUserInfoView.completeUserInfoViewEditInfo = ^(){
            EditPersonalInfoViewController *vc = [[EditPersonalInfoViewController alloc] init];
            vc.savePersonalInfoSuccess = ^{
            };
            [[self viewController].navigationController pushViewController:vc animated:YES];
        };
        return;
    }
    if(self.model.hasaskcheck.integerValue){
        NewAddFriendController *vc = [[NewAddFriendController alloc] init];
        vc.userID = self.model.userId;
        vc.realname = self.model.realname;
        vc.exchangeSuccess = ^(BOOL success){
            if(success){
                self.model.invite = @(1);
                self.addFriendBtn.hidden = NO;
                self.addFriendBtn.enabled = NO;
            }
        };
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }else{
        self.model.invite = @(2);
        sender.hidden = YES;
        self.activityIndicatorView.hidden = NO;
        [self.activityIndicatorView startAnimating];
        [self sendButtonClicked];
    }
}

#pragma mark -发送
- (void)sendButtonClicked{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    UserModel *userModel = [DataModelInstance shareInstance].userModel;
    [requestDict setObject:userModel.userId forKey:@"userid"];
    [requestDict setObject:self.model.userId forKey:@"other"];
    [requestDict setObject:@"1" forKey:@"isattent"];
    [requestDict setObject:@(0) forKey:@"sendvp"];
    [requestDict setObject:@"" forKey:@"audio"];
    NSString *workYear = @"";
    if([CommonMethod paramStringIsNull:userModel.worktime].length){
        workYear = [NSString stringWithFormat:@"%@年进入金融行业，",[userModel.worktime substringToIndex:4]];
    }
    [requestDict setObject:[NSString stringWithFormat:@"%@，你好！我是%@，我在%@担任%@，%@主要擅长%@，希望能与您交个朋友！", self.model.realname, userModel.realname,userModel.company,userModel.position,workYear,[CommonMethod paramStringIsNull:[userModel.goodjobs componentsJoinedByString:@"、"]]] forKey:@"remark"];
    [[self viewController] requstType:RequestType_Post apiName:API_NAME_USER_POST_ADDFRIENDS paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            weakSelf.model.invite = @(1);
            weakSelf.addFriendBtn.hidden = NO;
            weakSelf.addFriendBtn.enabled = NO;
            weakSelf.activityIndicatorView.hidden = YES;
            [weakSelf.activityIndicatorView stopAnimating];
        }else{
            weakSelf.model.invite = @(0);
            weakSelf.addFriendBtn.hidden = NO;
            weakSelf.addFriendBtn.enabled = YES;
            weakSelf.activityIndicatorView.hidden = YES;
            [weakSelf.activityIndicatorView stopAnimating];
            AddFriendError *errorView = [CommonMethod getViewFromNib:@"AddFriendError"];
            errorView.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
            [[UIApplication sharedApplication].keyWindow addSubview:errorView];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"发送失败" toView:[weakSelf viewController].view];
        weakSelf.model.invite = @(0);
        weakSelf.addFriendBtn.hidden = NO;
        weakSelf.addFriendBtn.enabled = YES;
        weakSelf.activityIndicatorView.hidden = YES;
        [weakSelf.activityIndicatorView stopAnimating];
    }];
}

@end
