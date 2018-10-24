//
//  WriteRateController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "WriteRateController.h"

@interface WriteRateController ()<UITextViewDelegate>{
    BOOL _publishDynamic;
}
@property (nonatomic,strong) UITextView *textView;
@property (nonatomic ,strong) UILabel *placeLabel;
@end

@implementation WriteRateController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar:@"发表评论"];
    self.textView = [[UITextView alloc]initWithFrame:CGRectMake(16, 70, WIDTH-32, HEIGHT - 63)];
    self.placeLabel = [UILabel createLabel:CGRectMake(8, 6, WIDTH - 32, 20) font:[UIFont systemFontOfSize:14] bkColor:[UIColor whiteColor] textColor:HEX_COLOR(@"afb6c1")];
    self.textView.delegate = self;
    self.textView.font = FONT_SYSTEM_SIZE(15);
    if (self.backRate == YES) {
        self.placeLabel.text = [NSString stringWithFormat:@"回复%@",self.nameStr];
        _publishDynamic = NO;
    }else{
        self.placeLabel.text = @"说点什么吧…";
        _publishDynamic = YES;
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 44)];
        contentView.backgroundColor = HEX_COLOR(@"f8f8f8");
        self.textView.inputAccessoryView = contentView;
        UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(16, 0, 75, 44) backColor:HEX_COLOR(@"f8f8f8") textColor:HEX_COLOR(@"818c9e") test:@"发布至动态" font:14 number:1 nstextLocat:NSTextAlignmentLeft];
        [contentView addSubview:titleLabel];
        UISwitch *switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(92, 7, 47, 27)];
        switchBtn.tintColor = HEX_COLOR(@"d8d8d8");
        switchBtn.backgroundColor = HEX_COLOR(@"f8f8f8");
        [switchBtn setOnTintColor:HEX_COLOR(@"1abc9c")];
        switchBtn.on = YES;
        [contentView addSubview:switchBtn];
        [switchBtn addTarget:self action:@selector(switchButtonClicked:) forControlEvents:UIControlEventValueChanged];
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 0.5)];
        lineLabel.backgroundColor = kCellLineColor;
        [contentView addSubview:lineLabel];
    }
    [self.textView addSubview:self.placeLabel];
    [self.view addSubview:self.textView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewEditChanged:)name:@"UITextViewTextDidChangeNotification"object:self.textView];
    UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    editBtn.frame = CGRectMake(WIDTH-60, 20, 50, 44);
    [editBtn setTitle:@"发表" forState:UIControlStateNormal];
    [editBtn setTitleColor:HEX_COLOR(@"e24943") forState:UIControlStateNormal];
    [editBtn setTitleColor:HEX_COLOR(@"e6e8eb") forState:UIControlStateDisabled];
    editBtn.titleLabel.font = FONT_SYSTEM_SIZE(16);
    [editBtn addTarget:self action:@selector(sendRateDetailButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    editBtn.enabled = NO;
    [self.view addSubview:editBtn];
    
    [self.textView becomeFirstResponder];
    
    [self.textView.rac_textSignal subscribeNext:^(NSString *text) {
        editBtn.enabled = text.length>0;
    }];
}

- (void)switchButtonClicked:(UISwitch*)sender{
    _publishDynamic = sender.on;
}

- (void)sendRateDetailButtonClicked{
    if (self.textView.text.length <= 0) {
        [MBProgressHUD showError:@"请输入评论" toView:self.view];
        return;
    }
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"发表中..." toView:self.view];
    NSString *apiType;
    if (self.backRate == YES) {
        apiType = API_NAME_GETRATE_SENDRATE;
    }else{
        apiType = API_NAME_TalkFINANACE_SENDRATE;
    }
    
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    if (self.backRate == YES) {
        [requestDict setObject:self.postID forKey:@"reviewid"];
    }else{
        [requestDict setObject:self.postID forKey:@"postid"];
    }
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    if(!self.textView.text.length){
        return;
    }
    [requestDict setObject:self.textView.text forKey:@"content"];
    if(_publishDynamic){
        [requestDict setObject:@(1) forKey:@"adddynamic"];
    }
    
    [self requstType:RequestType_Post apiName:apiType paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if ([self.writeRateControllerDelegate respondsToSelector:@selector(senderRateSuccendBack:)]) {
                [self.writeRateControllerDelegate senderRateSuccendBack:self.referType];
            }
            [self.textView resignFirstResponder];
            [MBProgressHUD showSuccess:@"发表成功" toView:weakSelf.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
    
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)textViewEditChanged:(NSNotification *)obj{
    UITextView *textField = (UITextView *)obj.object;
    if (textField.text.length > 0) {
        self.placeLabel.hidden = YES;
    }else{
        self.placeLabel.hidden = NO;
    }
}

- (void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length > 1000) {
        textView.text = [textView.text substringToIndex:1000];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)customNavBackButtonClicked{
    [self.textView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
