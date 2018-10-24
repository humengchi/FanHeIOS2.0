//
//  SearchFriendTableViewCell.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/22.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "SearchFriendTableViewCell.h"
#import "NewAddFriendController.h"
#import "EditPersonalInfoViewController.h"

@interface SearchFriendTableViewCell ()
@property (weak, nonatomic) IBOutlet UIButton *addFriendBtn;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rzImageView;
@property (weak, nonatomic) IBOutlet UIImageView *vipImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodJobLabel;
@property (weak, nonatomic) IBOutlet UIView *relationView;

@property (nonatomic, strong) ContactsModel *model;
@property (nonatomic, strong) SearchModel *searchModel;
@property (nonatomic, strong) TopicDetailModel *tdModel;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *isShowContastraint;

@end

@implementation SearchFriendTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateDisplaySearch:(SearchModel*)model showAddBtn:(BOOL)showAddBtn searchText:(NSString*)searchText{
    self.searchModel = model;
    if(showAddBtn){
        self.addFriendBtn.hidden = NO;
        self.isShowContastraint.constant = 56;
    }else{
        self.addFriendBtn.hidden = YES;
        self.isShowContastraint.constant = 0;
    }
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.name)];
    
    [self setLabelText:model.name searchText:searchText color:@"41464E" font:14 label:self.nameLabel];
    NSString *companyStr = [NSString stringWithFormat:@"%@%@", model.company, model.position];
    if(companyStr.length==0){
        companyStr = @"公司职位";
    }
    [self setLabelText:companyStr searchText:searchText color:@"818C9E" font:12 label:self.companyLabel];
    NSString *goodStr = [NSString stringWithFormat:@"#%@#", [model.tags componentsJoinedByString:@"# #"]];
    if(model.tags.count==0){
        goodStr = @"#擅长业务#";
    }
    [self setLabelText:goodStr searchText:searchText color:@"1ABC9C" font:12 label:self.goodJobLabel];
    self.rzImageView.hidden = model.hasValidUser.integerValue != 1;
    self.vipImageView.hidden = model.usertype.integerValue != 9;
    
    for(UIView *view in self.relationView.subviews){
        [view removeFromSuperview];
    }
    CGFloat start_X = 0;
    if([CommonMethod paramStringIsNull:model.relation].length){
        CGFloat strWidth = [NSHelper widthOfString:model.relation font:FONT_SYSTEM_SIZE(8) height:11]+15;
        UILabel *realtionLabel = [UILabel createrLabelframe:CGRectMake(start_X, 0, strWidth, 11) backColor:WHITE_COLOR textColor:HEX_COLOR(@"818c9e") test:model.relation font:8 number:1 nstextLocat:NSTextAlignmentCenter];
        [CALayer updateControlLayer:realtionLabel.layer radius:5.5 borderWidth:0.3 borderColor:HEX_COLOR(@"818c9e").CGColor];
        [self.relationView addSubview:realtionLabel];
        start_X += strWidth+6;
    }
    if([CommonMethod paramNumberIsNull:model.samefriend].integerValue){
        NSString *str = [NSString stringWithFormat:@"%@个共同好友", model.samefriend];
        CGFloat strWidth = [NSHelper widthOfString:str font:FONT_SYSTEM_SIZE(8) height:11]+15;
        UILabel *samefriendLabel = [UILabel createrLabelframe:CGRectMake(start_X, 0, strWidth, 11) backColor:WHITE_COLOR textColor:HEX_COLOR(@"818c9e") test:str font:8 number:1 nstextLocat:NSTextAlignmentCenter];
        [CALayer updateControlLayer:samefriendLabel.layer radius:5.5 borderWidth:0.3 borderColor:HEX_COLOR(@"818c9e").CGColor];
        [self.relationView addSubview:samefriendLabel];
        start_X += strWidth+6;
    }
}

- (void)setLabelText:(NSString*)text searchText:(NSString*)searchText color:(NSString*)color font:(CGFloat)font label:(UILabel*)label{
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:text];
    [atr setAttributes:@{NSFontAttributeName:FONT_SYSTEM_SIZE(font), NSForegroundColorAttributeName:HEX_COLOR(color)} range:NSMakeRange(0, text.length)];
    
    for(NSString *str in [searchText lowercaseString].componentsSeparated){
        NSRange range = [text rangeOfString:str];
        [atr setAttributes:@{NSFontAttributeName:FONT_SYSTEM_SIZE(font), NSForegroundColorAttributeName:kDefaultColor} range:range];
    }
    for(NSString *str in [searchText uppercaseString].componentsSeparated){
        NSRange range = [text rangeOfString:str];
        [atr setAttributes:@{NSFontAttributeName:FONT_SYSTEM_SIZE(font), NSForegroundColorAttributeName:kDefaultColor} range:range];
    }
    label.attributedText = atr;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateDisplay:(ContactsModel*)model tdModel:(TopicDetailModel*)tdModel searchText:(NSString*)searchText hideAddBtn:(BOOL)hideAddBtn{
    self.addFriendBtn.hidden = hideAddBtn;
    if(hideAddBtn==NO){
        self.isShowContastraint.constant = 56;
    }else{
        self.isShowContastraint.constant = 0;
    }
    self.model = model;
    self.tdModel = tdModel;
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
    
    [self setLabelText:model.realname searchText:searchText color:@"41464E" font:14 label:self.nameLabel];
    NSString *companyStr = [NSString stringWithFormat:@"%@%@", model.company, model.position];
    if(companyStr.length==0){
        companyStr = @"公司职位";
    }
    [self setLabelText:companyStr searchText:searchText color:@"818C9E" font:12 label:self.companyLabel];
    NSString *goodStr = [NSString stringWithFormat:@"#%@#", [model.goodjob componentsJoinedByString:@"# #"]];
    if(model.goodjob.count==0){
        goodStr = @"#擅长业务#";
    }
    [self setLabelText:goodStr searchText:searchText color:@"1ABC9C" font:12 label:self.goodJobLabel];
//    [self setLabelText:[NSString stringWithFormat:@"%@%@", model.company, model.position] searchText:searchText color:@"818C9E" font:12 label:self.companyLabel];
//    [self setLabelText:[NSString stringWithFormat:@"#%@#", [model.goodjob componentsJoinedByString:@"# #"]] searchText:searchText color:@"1ABC9C" font:12 label:self.goodJobLabel];
    self.rzImageView.hidden = model.hasValidUser.integerValue != 1;
    self.vipImageView.hidden = model.usertype.integerValue != 9;
    if(model.invite.intValue == 0){
        [self.addFriendBtn setTitle:@"邀请" forState:UIControlStateNormal];
    }else{
        [self.addFriendBtn setTitle:@"已邀请" forState:UIControlStateNormal];
        [self.addFriendBtn setTitleColor:HEX_COLOR(@"e6e8eb") forState:UIControlStateNormal];
        [self.addFriendBtn setBackgroundImage:nil forState:UIControlStateNormal];
        self.addFriendBtn.userInteractionEnabled = NO;
    }
    
    for(UIView *view in self.relationView.subviews){
        [view removeFromSuperview];
    }
    CGFloat start_X = 0;
    if([CommonMethod paramStringIsNull:model.relation].length){
        CGFloat strWidth = [NSHelper widthOfString:model.relation font:FONT_SYSTEM_SIZE(8) height:11]+15;
        UILabel *realtionLabel = [UILabel createrLabelframe:CGRectMake(start_X, 0, strWidth, 11) backColor:WHITE_COLOR textColor:HEX_COLOR(@"818c9e") test:model.relation font:8 number:1 nstextLocat:NSTextAlignmentCenter];
        [CALayer updateControlLayer:realtionLabel.layer radius:5.5 borderWidth:0.3 borderColor:HEX_COLOR(@"818c9e").CGColor];
        [self.relationView addSubview:realtionLabel];
        start_X += strWidth+6;
    }
    if([CommonMethod paramNumberIsNull:model.samefriend].integerValue){
        NSString *str = [NSString stringWithFormat:@"%@个共同好友", model.samefriend];
        CGFloat strWidth = [NSHelper widthOfString:str font:FONT_SYSTEM_SIZE(8) height:11]+15;
        UILabel *samefriendLabel = [UILabel createrLabelframe:CGRectMake(start_X, 0, strWidth, 11) backColor:WHITE_COLOR textColor:HEX_COLOR(@"818c9e") test:str font:8 number:1 nstextLocat:NSTextAlignmentCenter];
        [CALayer updateControlLayer:samefriendLabel.layer radius:5.5 borderWidth:0.3 borderColor:HEX_COLOR(@"818c9e").CGColor];
        [self.relationView addSubview:samefriendLabel];
        start_X += strWidth+6;
    }
}

#pragma mark - 添加好友
- (IBAction)addFriendButtonClicked:(id)sender{
    if(self.tdModel){
        [self inviteHttpData];
        return;
    }
    
    if(![CommonMethod getUserCanAddFriend]){
        CompleteUserInfoView *completeUserInfoView = [[CompleteUserInfoView alloc] initWithType:CompleteUserInfoViewType_AddFriend];
        completeUserInfoView.completeUserInfoViewEditInfo = ^(){
            EditPersonalInfoViewController *vc = [[EditPersonalInfoViewController alloc] init];
            [[self viewController].navigationController pushViewController:vc animated:YES];
        };
        return;
    }
    NewAddFriendController *vc = [[NewAddFriendController alloc] init];
    if(self.model){
        vc.userID = self.model.userid;
        vc.realname = self.model.realname;
    }else{
        vc.userID = self.searchModel.rid;
        vc.realname = self.searchModel.name;
    }
    [[self viewController].navigationController pushViewController:vc animated:YES];
}

#pragma mark - 邀请回答
- (void)inviteHttpData{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"邀请中..." toView:[self viewController].view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.model.userid forKey:@"inviteduserid"];
    [requestDict setObject:self.tdModel.subjectid forKey:@"subjectid"];
    [[[UIViewController alloc] init] requstType:RequestType_Post apiName:API_NAME_POST_INVITE_TALK paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            weakSelf.model.invite = @(1);
            [weakSelf.addFriendBtn setTitle:@"已邀请" forState:UIControlStateNormal];
            [weakSelf.addFriendBtn setTitleColor:HEX_COLOR(@"e6e8eb") forState:UIControlStateNormal];
            [weakSelf.addFriendBtn setBackgroundImage:nil forState:UIControlStateNormal];
            weakSelf.addFriendBtn.userInteractionEnabled = NO;
        }else{
            [hud hideAnimated:YES];
            [MBProgressHUD showError:@"无法连接到网络" toView:[weakSelf viewController].view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"无法连接到网络" toView:[weakSelf viewController].view];
    }];
}

@end
