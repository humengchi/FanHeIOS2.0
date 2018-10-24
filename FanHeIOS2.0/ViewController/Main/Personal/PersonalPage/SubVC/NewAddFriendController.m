//
//  NewAddFriendController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/2/8.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "NewAddFriendController.h"

@interface NewAddFriendController ()<UITextViewDelegate>{
    BOOL _isNeedAnswer;
    BOOL _isSelectTopic;
    BOOL _isShowInputAccessoryView;
    BOOL _notLimitedNumber;
}

@property (nonatomic, strong) UIButton *sendBtn;
@property (nonatomic, strong) UILabel *placeholder;
@property (nonatomic, strong) UILabel *numLabel;
@property (nonatomic, strong) UITextView *questionTextView;

@property (nonatomic, strong) NSArray *requestArray;

@property (nonatomic, strong) NSString *askcheck;

@end

@implementation NewAddFriendController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self removeViewTapGesture];
    [self createCustomNavigationBar:@"申请加好友"];
    UserModel *userModel = [DataModelInstance shareInstance].userModel;
    NSString *workYear = @"";
    if([CommonMethod paramStringIsNull:userModel.worktime].length){
        workYear = [NSString stringWithFormat:@"%@年进入金融行业，",[userModel.worktime substringToIndex:4]];
    }
    self.requestArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%@，你好！我是%@，我在%@担任%@，%@主要擅长%@，希望能与您交个朋友！", self.realname, userModel.realname,userModel.company,userModel.position,workYear,[CommonMethod paramStringIsNull:[userModel.goodjobs componentsJoinedByString:@"、"]]], [NSString stringWithFormat:@"%@，你好！有幸在3号圈看到你，我是%@，愿意加个好友深度沟通一下吗？", self.realname, userModel.realname], [NSString stringWithFormat:@"%@，你好！关注你很久了，希望能跟你认识一下，交个朋友。", self.realname], [NSString stringWithFormat:@"%@，你好！希望寻求%@方面的业务拓展，朋友向我推荐了你。", self.realname, [CommonMethod paramStringIsNull:[userModel.goodjobs componentsJoinedByString:@"、"]]], nil];
    self.sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendBtn.frame = CGRectMake(WIDTH-64, 20, 64, 44);
    [self.sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [self.sendBtn setTitleColor:HEX_COLOR(@"e24943") forState:UIControlStateNormal];
    [self.sendBtn setTitleColor:HEX_COLOR(@"e6e8eb") forState:UIControlStateDisabled];
    self.sendBtn.enabled = NO;
    self.sendBtn.titleLabel.font = FONT_SYSTEM_SIZE(16);
    [self.sendBtn addTarget:self action:@selector(sendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sendBtn];
    
    [self getPrivacyInfoHttpData];
}

- (void)createTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT-64) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = kTableViewBgColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 20)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 返回
- (void)customNavBackButtonClicked{
    if(self.questionTextView.text.length){
        [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"是否放弃编辑?" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:nil confirm:^{
            [self.view endEditing:YES];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -发送
- (void)sendButtonClicked:(UIButton*)sender{
    if(self.questionTextView.text.length==0){
        self.placeholder.hidden = NO;
        self.sendBtn.enabled = NO;
        self.numLabel.text = @"0/140";
        return;
    }
    [self.view endEditing:YES];
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"发送中..." toView:self.view];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.userID forKey:@"other"];
    [requestDict setObject:@"1" forKey:@"isattent"];
    [requestDict setObject:[NSNumber numberWithBool:_isSelectTopic] forKey:@"sendvp"];
    [requestDict setObject:@"" forKey:@"audio"];
    [requestDict setObject:self.questionTextView.text forKey:@"remark"];
    [self requstType:RequestType_Post apiName:API_NAME_USER_POST_ADDFRIENDS paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"发送成功" toView:self.view];
            if(weakSelf.exchangeSuccess){
                weakSelf.exchangeSuccess(YES);
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            });
        }else{
            AddFriendError *errorView = [CommonMethod getViewFromNib:@"AddFriendError"];
            errorView.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
            [[UIApplication sharedApplication].keyWindow addSubview:errorView];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showSuccess:@"发送失败" toView:self.view];
    }];
}

#pragma mark - 获取用户加好友的验证信息
- (void)getPrivacyInfoHttpData{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[NSString stringWithFormat:@"/%@",self.userID] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_TASK_CHECK paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            NSDictionary *dict = [CommonMethod paramDictIsNull:responseObject[@"data"]];
            if([CommonMethod paramNumberIsNull:dict[@"hasaskcheck"]].integerValue){
                _isNeedAnswer = YES;
                weakSelf.askcheck = [CommonMethod paramStringIsNull:dict[@"askcheck"]];
            }else{
                _isNeedAnswer = NO;
            }
            if([CommonMethod paramNumberIsNull:dict[@"hasaskcheck"]].integerValue==2){
                _notLimitedNumber = YES;
                if([CommonMethod paramNumberIsNull:dict[@"subjectstatus"]].integerValue==1){
                    _isSelectTopic = YES;
                    _isShowInputAccessoryView = YES;
                }
            }
            [weakSelf createTableView];
        }else{
            [MBProgressHUD showError:@"网络连接失败，请检查网络" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络连接失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark -- UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(_isNeedAnswer){
        return 1;
    }else{
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section==1){
        return 4;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        if(_isNeedAnswer){
            return 60+[NSHelper heightOfString:self.askcheck font:FONT_SYSTEM_SIZE(15) width:WIDTH-25];
        }else{
            return 47;
        }
    }else{
        return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0){
        return 257;
    }else{
        return 36+[NSHelper heightOfString:self.requestArray[indexPath.row] font:FONT_SYSTEM_SIZE(15) width:WIDTH-56];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.00001;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 0){
        if(_isNeedAnswer){
            UIView *HeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 96)];
            HeaderView.backgroundColor = kTableViewBgColor;
            NSString *str = @"希望你回答Ta的问题";
            if(_isShowInputAccessoryView){
                str = @"希望了解你对以下话题的观点";
            }
            UILabel *nameLabel = [UILabel createLabel:CGRectMake(25, 16, WIDTH-50, 17) font:FONT_SYSTEM_SIZE(15) bkColor:kTableViewBgColor textColor:KTextColor];
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", self.realname, str]];
            [attr addAttributes:@{NSForegroundColorAttributeName:HEX_COLOR(@"3498db")} range:NSMakeRange(0, [CommonMethod paramStringIsNull:self.realname].length)];
            nameLabel.attributedText = attr;
            [HeaderView addSubview:nameLabel];
            
            UILabel *question = [UILabel createrLabelframe:CGRectMake(25, 43, WIDTH-50, (NSInteger)[NSHelper heightOfString:self.askcheck font:FONT_SYSTEM_SIZE(15) width:WIDTH-25]+1) backColor:kTableViewBgColor textColor:HEX_COLOR(@"41464e") test:self.askcheck font:15 number:0 nstextLocat:NSTextAlignmentLeft];
            [HeaderView addSubview:question];
            return HeaderView;
        }else{
            UIView *HeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 47)];
            HeaderView.backgroundColor = kTableViewBgColor;
            UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(25, 0, WIDTH-50, 47) backColor:kTableViewBgColor textColor:KTextColor test:@"介绍一下自己吧：" font:15 number:1 nstextLocat:NSTextAlignmentLeft];
            [HeaderView addSubview:contentLabel];
            return HeaderView;
        }
    }else{
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    for(UIView *view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
    cell.backgroundColor = WHITE_COLOR;
    if(indexPath.section==0){
        self.placeholder = [UILabel createLabel:CGRectMake(25, 20, WIDTH-32, 17) font:FONT_SYSTEM_SIZE(15) bkColor:[UIColor clearColor] textColor:HEX_COLOR(@"afb6c1")];
        if(_isNeedAnswer){
            self.placeholder.text = @"请输入你的回答";
        }else{
            self.placeholder.text = @"输入你的介绍";
        }
        self.numLabel = [UILabel createLabel:CGRectMake(25, 231, WIDTH-50, 14) font:FONT_SYSTEM_SIZE(12) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"afb6c1")];
        self.numLabel.text = @"0/140";
        self.numLabel.textAlignment = NSTextAlignmentRight;
        if(_notLimitedNumber){
            self.numLabel.hidden = YES;
        }
        self.questionTextView = [[UITextView alloc] initWithFrame:CGRectMake(25, 20, WIDTH-50, 210)];
        self.questionTextView.textContainerInset = UIEdgeInsetsMake(-2, -5, 10, -5);
        self.questionTextView.textColor = HEX_COLOR(@"41464e");
        self.questionTextView.font = FONT_SYSTEM_SIZE(15);
        self.questionTextView.delegate = self;
        self.questionTextView.returnKeyType = UIReturnKeyDone;
        [self.questionTextView.rac_textSignal subscribeNext:^(NSString *text) {
            if(text.length==0){
                self.placeholder.hidden = NO;
                self.sendBtn.enabled = NO;
                self.numLabel.text = @"0/140";
            }
        }];
        if(_isNeedAnswer){
            [self.questionTextView becomeFirstResponder];
            if(_isShowInputAccessoryView){
                UIView *toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 44)];
                toolbar.backgroundColor = HEX_COLOR(@"f8f8f8");
                UIButton *choiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                choiceBtn.frame = CGRectMake(16, 0, 180, 44);
                [choiceBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
                [choiceBtn setImage:kImageWithName(@"btn_check_box_off") forState:UIControlStateNormal];
                [choiceBtn setImage:kImageWithName(@"btn_check_box_on") forState:UIControlStateSelected];
                [choiceBtn setTitle:@" 将我的观点发布到话题下" forState:UIControlStateNormal];
                choiceBtn.titleLabel.font = FONT_SYSTEM_SIZE(14);
                [choiceBtn setTitleColor:KTextColor forState:UIControlStateNormal];
                [choiceBtn addTarget:self action:@selector(choiceButtonCliced:) forControlEvents:UIControlEventTouchUpInside];
                choiceBtn.selected = _isSelectTopic;
                [toolbar addSubview:choiceBtn];
                self.questionTextView.inputAccessoryView = toolbar;
            }
        }
        [cell.contentView addSubview:self.questionTextView];
        [cell.contentView addSubview:self.placeholder];
        [cell.contentView addSubview:self.numLabel];
    }else{
        cell.backgroundColor = kTableViewBgColor;
        CGFloat textHeight = [NSHelper heightOfString:self.requestArray[indexPath.row] font:FONT_SYSTEM_SIZE(15) width:WIDTH-56]+24;
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(16, 12, WIDTH-32, textHeight)];
        contentView.tag = 200;
        contentView.backgroundColor = WHITE_COLOR;
        [CALayer updateControlLayer:contentView.layer radius:5 borderWidth:0.5 borderColor:kCellLineColor.CGColor];
        [cell.contentView addSubview:contentView];
        
        UILabel *contentLabel = [UILabel createLabel:CGRectMake(12, 0, WIDTH-56, textHeight) font:FONT_SYSTEM_SIZE(15) bkColor:[UIColor clearColor] textColor:HEX_COLOR(@"41464e")];
        contentLabel.numberOfLines = 0;
        contentLabel.text = self.requestArray[indexPath.row];
        [contentView addSubview:contentLabel];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIView *contentView = [cell.contentView subviewWithTag:200];
        [UIView animateWithDuration:0.2 animations:^{
            contentView.backgroundColor = kCellLineColor;
        } completion:^(BOOL finished) {
            contentView.backgroundColor = WHITE_COLOR;
        }];
        self.questionTextView.text = self.requestArray[indexPath.row];
        self.placeholder.hidden = self.questionTextView.text.length>0;
        self.sendBtn.enabled = self.questionTextView.text.length>0;
        self.numLabel.text = [NSString stringWithFormat:@"%ld/140", self.questionTextView.text.length];
    }
}

#pragma mark - 回答问题是否同步到话题中
- (void)choiceButtonCliced:(UIButton*)btn{
    [btn setSelected:!btn.selected];
    _isSelectTopic = btn.selected;
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    }
    UITextRange *selectedRange = [textView markedTextRange];
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    if(position && (range.length==0 || text.length==0)){
        return YES;
    }else{
        NSString *str = [textView.text stringByReplacingCharactersInRange:NSMakeRange(range.location, range.length) withString:text];
        if(str.length>140&&!_notLimitedNumber){
            textView.text = [str substringToIndex:140];
            self.placeholder.hidden = textView.text.length>0;
            self.sendBtn.enabled = textView.text.length>0;
            self.numLabel.text = [NSString stringWithFormat:@"%ld/140", textView.text.length];
            return NO;
        }else{
            self.placeholder.hidden = str.length>0;
            self.sendBtn.enabled = str.length>0;
            self.numLabel.text = [NSString stringWithFormat:@"%ld/140", str.length];
        }
    }
    return YES;
}

#pragma mark - Keyboard status
- (void)keyboardWillShowOrHide:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardEnd = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardEnd.size.height;
    [UIView animateWithDuration:duration animations:^{
        if([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
            self.tableView.frame = CGRectMake(0, 64, WIDTH, HEIGHT-64-keyboardHeight);
        }else{
            self.tableView.frame = CGRectMake(0, 64, WIDTH, HEIGHT-64);
        }
    }];
}

@end
