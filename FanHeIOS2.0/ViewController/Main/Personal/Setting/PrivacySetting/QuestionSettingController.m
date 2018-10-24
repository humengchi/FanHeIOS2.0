//
//  QuestionSettingController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/2/8.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "QuestionSettingController.h"

@interface QuestionSettingController ()<UITextViewDelegate>

@property (nonatomic, strong) NSString *askcheck;
@property (nonatomic, strong) NSNumber *asksubjectid;
@property (nonatomic, strong) NSNumber *hasaskcheck;
@property (nonatomic, strong) NSString *asksubject;

@property (nonatomic, strong) UIButton *saveBtn;
@property (nonatomic, strong) UILabel *placeholder;
@property (nonatomic, strong) UILabel *numLabel;

@property (nonatomic, strong) NSMutableArray *topicArray;

@end

@implementation QuestionSettingController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.topicArray = [NSMutableArray array];
    
    self.hasaskcheck = [CommonMethod paramNumberIsNull:[DataModelInstance shareInstance].userModel.hasaskcheck];
    self.askcheck = [CommonMethod paramStringIsNull:[DataModelInstance shareInstance].userModel.askcheck];
    self.asksubject = [CommonMethod paramStringIsNull:[DataModelInstance shareInstance].userModel.asksubject];
    self.asksubjectid = [CommonMethod paramNumberIsNull:[DataModelInstance shareInstance].userModel.asksubjectid];
    
    [self createCustomNavigationBar:@"设置问题"];
    
    self.saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.saveBtn.frame = CGRectMake(WIDTH-64, 20, 64, 44);
    [self.saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [self.saveBtn setTitleColor:HEX_COLOR(@"e24943") forState:UIControlStateNormal];
    [self.saveBtn setTitleColor:HEX_COLOR(@"e6e8eb") forState:UIControlStateDisabled];
    self.saveBtn.enabled = NO;
    [self.saveBtn addTarget:self action:@selector(saveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.saveBtn];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT-64) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = kTableViewBgColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self getRmdTopicHttpData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 返回
- (void)customNavBackButtonClicked{
    UserModel *model = [DataModelInstance shareInstance].userModel;
    if([CommonMethod paramNumberIsNull:model.hasaskcheck].integerValue != self.hasaskcheck.integerValue || ![[CommonMethod paramStringIsNull:model.askcheck] isEqualToString:self.askcheck] || [CommonMethod paramNumberIsNull:model.asksubjectid].integerValue != self.asksubjectid.integerValue){
        [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"是否放弃编辑?" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:nil confirm:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -保存
- (void)saveButtonClicked:(UIButton*)sender{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"保存中..." toView:self.view];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.hasaskcheck forKey:@"hasaskcheck"];
    if(self.hasaskcheck.integerValue==0){
        self.askcheck = @"";
        self.asksubjectid = [NSNumber numberWithInt:0];
        self.asksubject = @"";
    }
    if(self.askcheck.length){
        self.asksubjectid = [NSNumber numberWithInt:0];
        self.asksubject = @"";
    }
    [requestDict setObject:self.askcheck forKey:@"askcheck"];
    [requestDict setObject:self.asksubjectid forKey:@"asksubjectid"];
    [self requstType:RequestType_Post apiName:API_NAME_POST_UP_ASK_CHECK paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            UserModel *model = [DataModelInstance shareInstance].userModel;
            model.hasaskcheck = weakSelf.hasaskcheck;
            model.askcheck = weakSelf.askcheck;
            model.asksubjectid = weakSelf.asksubjectid;
            model.asksubject = weakSelf.asksubject;
            [DataModelInstance shareInstance].userModel = model;
            [MBProgressHUD showSuccess:@"保存成功" toView:weakSelf.view];
            if(weakSelf.questionSettingSuccess){
                weakSelf.questionSettingSuccess();
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }else{
            [MBProgressHUD showError:@"网络连接失败，请重试" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络连接失败，请重试" toView:weakSelf.view];
    }];
}

#pragma mark - 验证话题推荐网络数据
- (void)getRmdTopicHttpData{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[NSString stringWithFormat:@"/%@",[DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_RMD_ASK_CHECK paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            for(NSDictionary *dict in [CommonMethod paramArrayIsNull:responseObject[@"data"]]){
                TopicDetailModel *model = [[TopicDetailModel alloc] initWithDict:dict];
                [weakSelf.topicArray addObject:model];
            }
            if(weakSelf.topicArray.count){
                [weakSelf.tableView reloadData];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

#pragma mark -- UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(self.hasaskcheck.integerValue==1){
        if(self.topicArray.count){
            return 3;
        }else{
            return 2;
        }
    }else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section==2){
        return self.topicArray.count;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 2){
        return 47;
    }else{
        return 5;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==1){
        return 98;
    }else if(indexPath.section==2){
        TopicDetailModel *model = self.topicArray[indexPath.row];
        return 36+[NSHelper heightOfString:model.title font:FONT_SYSTEM_SIZE(15) width:WIDTH-85];
    }else{
        return 49;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.00001;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 2){
        UIView *HeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 47)];
        HeaderView.backgroundColor = kTableViewBgColor;
        UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(16, 0, WIDTH-32, 47) backColor:kTableViewBgColor textColor:KTextColor test:@"使用推荐问题：" font:15 number:1 nstextLocat:NSTextAlignmentLeft];
        [HeaderView addSubview:contentLabel];
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 0.5)];
        lineLabel.backgroundColor = kCellLineColor;
        [HeaderView addSubview:lineLabel];
        return HeaderView;
    }else{
        UIView *HeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 5)];
        HeaderView.backgroundColor = kTableViewBgColor;
        return HeaderView;
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
        UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(16, 0, WIDTH-32, 49) backColor:WHITE_COLOR textColor:KTextColor test:@"" font:17 number:1 nstextLocat:NSTextAlignmentLeft];
        [cell.contentView addSubview:titleLabel];
        titleLabel.text = @"开启加好友问题验证";
        UISwitch *switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(WIDTH-67, 9, 51, 31)];
        [switchBtn addTarget:self action:@selector(switchButtonClicked:) forControlEvents:UIControlEventValueChanged];
        switchBtn.on = self.hasaskcheck.boolValue;
        [cell.contentView addSubview:switchBtn];
    }else if(indexPath.section==1){
        self.placeholder = [UILabel createLabel:CGRectMake(25, 20, WIDTH-32, 17) font:FONT_SYSTEM_SIZE(15) bkColor:[UIColor clearColor] textColor:HEX_COLOR(@"afb6c1")];
        self.placeholder.text = @"请输入希望对方回答的问题...";
        self.numLabel = [UILabel createLabel:CGRectMake(25, 76, WIDTH-50, 14) font:FONT_SYSTEM_SIZE(12) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"afb6c1")];
        self.numLabel.text = @"0/50";
        self.numLabel.textAlignment = NSTextAlignmentRight;
        UITextView *textview = [[UITextView alloc] initWithFrame:CGRectMake(25, 20, WIDTH-50, 55)];
        textview.textContainerInset = UIEdgeInsetsMake(-2, -5, 0, 0);
        textview.textColor = HEX_COLOR(@"41464e");
        textview.font = FONT_SYSTEM_SIZE(15);
        textview.delegate = self;
        textview.returnKeyType = UIReturnKeyDone;
        textview.text = self.askcheck;
        self.placeholder.hidden = self.askcheck.length>0;
        self.saveBtn.enabled = self.askcheck.length>0;
        self.numLabel.text = [NSString stringWithFormat:@"%ld/50", self.askcheck.length];
        [textview.rac_textSignal subscribeNext:^(NSString *text) {
            if(text.length==0){
                self.placeholder.hidden = NO;
                self.saveBtn.enabled = NO;
                self.numLabel.text = @"0/50";
                self.askcheck = @"";
            }
        }];
        [cell.contentView addSubview:textview];
        [cell.contentView addSubview:self.placeholder];
        [cell.contentView addSubview:self.numLabel];
    }else{
        cell.backgroundColor = kTableViewBgColor;
        TopicDetailModel *model = self.topicArray[indexPath.row];
        NSString *textColor = @"41464e";
        NSString *lineColor = @"d9d9d9";
        if(self.askcheck.length==0 && model.subjectid.integerValue==self.asksubjectid.integerValue){
            textColor = @"1abc9c";
            lineColor = textColor;
        }
        CGFloat height = [NSHelper heightOfString:model.title font:FONT_SYSTEM_SIZE(15) width:WIDTH-85]+24;
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(16, 0, WIDTH-32, height)];
        contentView.backgroundColor = WHITE_COLOR;
        [CALayer updateControlLayer:contentView.layer radius:5 borderWidth:0.5 borderColor:HEX_COLOR(lineColor).CGColor];
        [cell.contentView addSubview:contentView];
        
        UILabel *contentLabel = [UILabel createLabel:CGRectMake(12, 0, WIDTH-85, height) font:FONT_SYSTEM_SIZE(15) bkColor:WHITE_COLOR textColor:HEX_COLOR(textColor)];
        contentLabel.numberOfLines = 0;
        contentLabel.text = model.title;
        [contentView addSubview:contentLabel];
        
        if(self.askcheck.length==0 && self.asksubjectid.integerValue == model.subjectid.integerValue){
            UIImageView *selectedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-65, (height-21)/2, 21, 21)];
            selectedImageView.image = kImageWithName(@"btn_zy_sc_y");
            [contentView addSubview:selectedImageView];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 2) {
        TopicDetailModel *model = self.topicArray[indexPath.row];
        self.askcheck = @"";
        self.asksubject = model.title;
        self.asksubjectid = model.subjectid;
        [self.tableView reloadData];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self saveButtonClicked:nil];
        });
    }
}

#pragma mark - UISwitch
- (void)switchButtonClicked:(UISwitch*)sender{
    self.hasaskcheck = [NSNumber numberWithBool:sender.isOn];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    if(self.hasaskcheck.integerValue==0){
        self.saveBtn.enabled = YES;
    }else if(self.askcheck.length){
        self.saveBtn.enabled = YES;
    }else{
        self.saveBtn.enabled = NO;
    }
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
        if(str.length>50){
            textView.text = [str substringToIndex:50];
            self.placeholder.hidden = textView.text.length>0;
            self.saveBtn.enabled = textView.text.length>0;
            self.numLabel.text = [NSString stringWithFormat:@"%ld/50", textView.text.length];
            self.askcheck = textView.text;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
            return NO;
        }else{
            self.placeholder.hidden = str.length>0;
            self.saveBtn.enabled = str.length>0;
            self.numLabel.text = [NSString stringWithFormat:@"%ld/50", str.length];
            self.askcheck = str;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    return YES;
}

@end
