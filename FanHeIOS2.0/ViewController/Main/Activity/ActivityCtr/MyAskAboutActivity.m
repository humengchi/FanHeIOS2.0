//
//  MyAskAboutActivity.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "MyAskAboutActivity.h"

@interface MyAskAboutActivity ()<UITextViewDelegate>
@property (nonatomic,strong) UITextView *textView;
@property (nonatomic ,strong) UILabel *placeLabel;
@property (nonatomic ,strong) UILabel *titleLabel;
@property (nonatomic ,strong) UIButton *editBtn;
@end

@implementation MyAskAboutActivity

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createCustomNavigationBar:@"提问"];
    self.textView = [[UITextView alloc]initWithFrame:CGRectMake(16, 70, WIDTH-32, HEIGHT - 63)];
    self.textView.textColor = [UIColor colorWithHexString:@"41464E"];
    self.textView.font = [UIFont systemFontOfSize:15];
    self.textView.returnKeyType = UIReturnKeySend;
    self.placeLabel = [UILabel createLabel:CGRectMake(10, 6, WIDTH - 32, 20) font:[UIFont systemFontOfSize:15] bkColor:[UIColor whiteColor] textColor:[UIColor colorWithHexString:@"AFB6C1"]];
    self.textView.delegate = self;
    self.placeLabel.text = @"写下你想问主办方的问题，4-40个字";
    [self.textView addSubview:self.placeLabel];
    [self.view addSubview:self.textView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewEditChanged:)name:@"UITextViewTextDidChangeNotification"object:self.textView];
     self.editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.editBtn.frame = CGRectMake(WIDTH-60, 20, 50, 44);
    [self.editBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self.editBtn setTitleColor:HEX_COLOR(@"E6E8EB") forState:UIControlStateNormal];
     self.editBtn.userInteractionEnabled = NO;
    self.editBtn.titleLabel.font = FONT_SYSTEM_SIZE(16);
    [self.editBtn addTarget:self action:@selector(sendRateDetailButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.editBtn];
    self.titleLabel = [UILabel createLabel:CGRectMake(0, self.view.frame.size.height - 40, WIDTH -16, 21) font:[UIFont systemFontOfSize:12] bkColor:[UIColor whiteColor] textColor:[UIColor colorWithHexString:@"AFB6C1"]];
    self.titleLabel.textAlignment = NSTextAlignmentRight;
    self.titleLabel.text = @"0/40";
    [self.view addSubview:self.titleLabel];
    
    [self.textView becomeFirstResponder];
    //Add keyboard notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardNotification:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardNotification:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        [self sendRateDetailButtonClicked];
        return NO;
    }
    return YES;
}
- (void)sendRateDetailButtonClicked{
    
    if (self.textView.text.length < 4) {
        [self.view showToastMessage:@"最少输入四个字"];
        return;
    }
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"发表中..." toView:self.view];
    NSString *apiType = API_NAME_POST_ACTIVITY_ASK;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.activityid forKey:@"activityid"];
    [requestDict setObject:self.textView.text forKey:@"content"];
    
    [self requstType:RequestType_Post apiName:apiType paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if ([self.myAskAboutActivityDelegate respondsToSelector:@selector(referAskView)]) {
                [self.myAskAboutActivityDelegate referAskView];
            }
            [self showHint:@"发表成功"];
            [self.textView resignFirstResponder];
            [self dismissViewControllerAnimated:YES completion:nil];
           
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
    
}

#pragma mark - Keyboard notification
- (void)onKeyboardNotification:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardEnd = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardEnd.size.height;
    [UIView animateWithDuration:duration animations:^{
        if([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
            self.view.frame = CGRectMake(0, 0, WIDTH, HEIGHT-keyboardHeight);
        }else{
            self.view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        }
        self.titleLabel.frame = CGRectMake(0, self.view.frame.size.height - 40, WIDTH -16, 21);
    }];
}

-(void)textViewEditChanged:(NSNotification *)obj{
    UITextView *textField = (UITextView *)obj.object;
    if (textField.text.length > 0) {
        [self.editBtn setTitleColor:HEX_COLOR(@"E24943") forState:UIControlStateNormal];
         self.editBtn.userInteractionEnabled = YES;
        self.placeLabel.hidden = YES;
    }else{
        [self.editBtn setTitleColor:HEX_COLOR(@"E6E8EB") forState:UIControlStateNormal];
        self.editBtn.userInteractionEnabled = NO;
        self.placeLabel.hidden = NO;
    }
    if (textField.text.length > 40 ) {
        self.textView.text = [self.textView.text substringToIndex:40];
    }else{
        self.titleLabel.text = [NSString stringWithFormat:@"%ld/40",textField.text.length];
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
