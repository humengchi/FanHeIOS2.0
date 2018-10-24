//
//  ContactsCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/3.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ContactsCell.h"
#import "NewAddFriendController.h"
#import "EditPersonalInfoViewController.h"

@interface ContactsCell ()

@property (weak, nonatomic) IBOutlet UIImageView *hasValidUserView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *usertypeImageView;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *tagsView;

@property (weak, nonatomic) IBOutlet UILabel *goodJobLabel;

@property (weak, nonatomic) IBOutlet UIImageView *needImageView;
@property (weak, nonatomic) IBOutlet UILabel *needLabel;
@property (weak, nonatomic) IBOutlet UIImageView *supplyImageView;
@property (weak, nonatomic) IBOutlet UILabel *supplyLabel;
@property (weak, nonatomic) IBOutlet UILabel *lineLabel;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIButton *addFriendBtn;

@property (nonatomic, strong) ContactsModel *model;

@end

@implementation ContactsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [CALayer updateControlLayer:self.headerImageView.layer radius:22 borderWidth:0 borderColor:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateDisplay:(ContactsModel*)model{
    self.model = model;
    self.usertypeImageView.hidden = model.usertype.integerValue!=9;
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
    self.companyLabel.text = [NSString stringWithFormat:@"%@%@",[CommonMethod paramStringIsNull:model.company],[CommonMethod paramStringIsNull:model.position]];
    
    self.nameLabel.text = model.realname;
    self.hasValidUserView.hidden = model.hasValidUser.integerValue!=1;
    
    self.goodJobLabel.text = [NSString stringWithFormat:@"#%@# ",[[CommonMethod paramArrayIsNull:model.goodjob] componentsJoinedByString:@"# #"]];
    
    self.needLabel.hidden = YES;
    self.needImageView.hidden = YES;
    self.supplyLabel.hidden = YES;
    self.supplyImageView.hidden = YES;
    self.lineLabel.hidden = YES;
    NSString *needStr = [CommonMethod paramStringIsNull:model.need];
    NSString *supplyStr = [CommonMethod paramStringIsNull:model.supply];
    if(needStr.length && supplyStr.length){
        self.needLabel.text = needStr;
        self.needImageView.image = kImageWithName(@"icon_rm_need");
        self.supplyLabel.text = supplyStr;
        self.supplyImageView.image = kImageWithName(@"icon_rm_supply");
        self.needLabel.hidden = NO;
        self.needImageView.hidden = NO;
        self.supplyLabel.hidden = NO;
        self.supplyImageView.hidden = NO;
        self.lineLabel.hidden = NO;
    }else if(needStr.length && supplyStr.length==0){
        self.needLabel.text = needStr;
        self.needImageView.image = kImageWithName(@"icon_rm_need");
        self.needLabel.hidden = NO;
        self.needImageView.hidden = NO;
    }else if(needStr.length==0 && supplyStr.length){
        self.needLabel.text = supplyStr;
        self.needImageView.image = kImageWithName(@"icon_rm_supply");
        self.needLabel.hidden = NO;
        self.needImageView.hidden = NO;
    }
    
    for(UIView *view in self.tagsView.subviews){
        [view removeFromSuperview];
    }
    CGFloat start_X = 0;
    if([CommonMethod paramStringIsNull:model.relation].length){
        CGFloat strWidth = [NSHelper widthOfString:model.relation font:FONT_SYSTEM_SIZE(8) height:11]+15;
        UILabel *realtionLabel = [UILabel createrLabelframe:CGRectMake(start_X, 0, strWidth, 11) backColor:WHITE_COLOR textColor:HEX_COLOR(@"818c9e") test:model.relation font:8 number:1 nstextLocat:NSTextAlignmentCenter];
        [CALayer updateControlLayer:realtionLabel.layer radius:5.5 borderWidth:0.3 borderColor:HEX_COLOR(@"818c9e").CGColor];
        [self.tagsView addSubview:realtionLabel];
        start_X += strWidth+6;
    }
    if([CommonMethod paramNumberIsNull:model.samefriend].integerValue){
        NSString *str = [NSString stringWithFormat:@"%@个共同好友", model.samefriend];
        CGFloat strWidth = [NSHelper widthOfString:str font:FONT_SYSTEM_SIZE(8) height:11]+15;
        UILabel *samefriendLabel = [UILabel createrLabelframe:CGRectMake(start_X, 0, strWidth, 11) backColor:WHITE_COLOR textColor:HEX_COLOR(@"818c9e") test:str font:8 number:1 nstextLocat:NSTextAlignmentCenter];
        [CALayer updateControlLayer:samefriendLabel.layer radius:5.5 borderWidth:0.3 borderColor:HEX_COLOR(@"818c9e").CGColor];
        [self.tagsView addSubview:samefriendLabel];
        start_X += strWidth+6;
    }
    if([CommonMethod paramNumberIsNull:model.othericon].integerValue == 1){
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(start_X, 0, 31, 11)];
        iconImageView.image = kImageWithName(@"icon_zy_zf");
        [self.tagsView addSubview:iconImageView];
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

- (void)setLabelTextAttri:(UILabel*)label text:(NSString*)text{
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:text];
    [AttributedStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(0, text.length-2)];
    [AttributedStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:9] range:NSMakeRange(text.length-2, 2)];
    
    [label setAttributedText:AttributedStr];
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
        vc.userID = self.model.userid;
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
    [requestDict setObject:self.model.userid forKey:@"other"];
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
