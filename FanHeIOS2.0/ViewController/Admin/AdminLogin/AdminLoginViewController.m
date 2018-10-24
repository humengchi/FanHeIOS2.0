//
//  AdminLoginViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/6/21.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "AdminLoginViewController.h"
#import "ForgetPasswdViewController.h"

@interface AdminLoginViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwdTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *mobileIsRightBtn;
@property (weak, nonatomic) IBOutlet UIButton *passwdIsRightBtn;
@property (weak, nonatomic) IBOutlet UILabel *mobileErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwdErrorLabel;

@end

@implementation AdminLoginViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.mobileTextField becomeFirstResponder];
    [self.mobileTextField setValue:HEX_COLOR(@"AFB6C1") forKeyPath:@"_placeholderLabel.textColor"];
    [self.passwdTextField setValue:HEX_COLOR(@"AFB6C1") forKeyPath:@"_placeholderLabel.textColor"];
    __weak typeof(self) weakSelf = self;
    [self.mobileTextField.rac_textSignal subscribeNext:^(NSString *text) {
        weakSelf.mobileErrorLabel.hidden = YES;
        if(weakSelf.mobileTextField.text.length){
            weakSelf.mobileIsRightBtn.hidden = NO;
            weakSelf.mobileIsRightBtn.selected = NO;
        }else{
            weakSelf.mobileIsRightBtn.hidden = YES;
        }
    }];
    [self.passwdTextField.rac_textSignal subscribeNext:^(NSString *text) {
        if(self.passwdTextField.text.length == 0){
            self.passwdTextField.font = FONT_SYSTEM_SIZE(24);
        }else{
            self.passwdTextField.font = FONT_SYSTEM_SIZE(18);
        }
        weakSelf.passwdErrorLabel.hidden = YES;
        if(text.length >= 6){
            weakSelf.passwdIsRightBtn.hidden = NO;
            if(text.length <= 20){
                weakSelf.passwdIsRightBtn.selected = NO;
            }else{
                weakSelf.passwdIsRightBtn.selected = YES;
                weakSelf.passwdErrorLabel.hidden = NO;
                weakSelf.passwdErrorLabel.text = @"密码为6~20个字符";
                weakSelf.passwdTextField.text = [text substringToIndex:20];
            }
        }else{
            weakSelf.passwdIsRightBtn.hidden = YES;
        }
    }];
    RAC(self.loginBtn, enabled) = [RACSignal combineLatest:@[self.mobileTextField.rac_textSignal, self.passwdTextField.rac_textSignal] reduce:^id(NSString *text1, NSString *text2){
        if(text1.length && text2.length >= 6){
            return @(1);
        }else{
            return @(0);
        }
    }];
    
    RACSignal *btnSignal = [self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside];
    [btnSignal subscribeNext:^(UIButton *button) {
        
    }];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - method
- (IBAction)loginButtonClicked:(UIButton *)sender{
    [self.view endEditing:YES];
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"登录中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:self.mobileTextField.text forKey:@"username"];
    [requestDict setObject:self.passwdTextField.text forKey:@"passwd"];
    
    [self requstType:RequestType_Post apiName:API_NAME_ADMIN_LOGIN paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        weakSelf.mobileErrorLabel.hidden = YES;
        weakSelf.mobileIsRightBtn.hidden = YES;
        weakSelf.passwdErrorLabel.hidden = YES;
        weakSelf.passwdIsRightBtn.hidden = YES;
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            AdminModel *model = [[AdminModel alloc] initWithDict:[responseObject objectForKey:@"data"]];
            [DataModelInstance shareInstance].adminUserModel = model;
            [[AppDelegate shareInstance] gotoAdminMainVC];
        }else if([[responseObject objectForKey:@"msg"] isEqualToString:@"该手机号未注册！"]){
            [weakSelf.mobileTextField becomeFirstResponder];
            weakSelf.mobileErrorLabel.hidden = NO;
            weakSelf.mobileErrorLabel.text = @"当前账号不存在";
            weakSelf.mobileIsRightBtn.hidden = NO;
            weakSelf.mobileIsRightBtn.selected = YES;
            weakSelf.passwdIsRightBtn.hidden = NO;
        }else if([[responseObject objectForKey:@"msg"] isEqualToString:@"密码不正确！"]){
            [weakSelf.passwdTextField becomeFirstResponder];
            weakSelf.passwdErrorLabel.hidden = NO;
            weakSelf.passwdErrorLabel.text = @"用户名或密码错误";
            weakSelf.passwdIsRightBtn.hidden = NO;
            weakSelf.passwdIsRightBtn.selected = YES;
            weakSelf.mobileIsRightBtn.hidden = NO;
        }else{
            [MBProgressHUD showError:[responseObject objectForKey:@"msg"] toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

- (IBAction)backNavButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)forgetPasswdButtonClicked:(id)sender{
    ForgetPasswdViewController *vc = [CommonMethod getVCFromNib:[ForgetPasswdViewController class]];
    vc.phoneStr = self.mobileTextField.text;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)codeLoginButtonClicked:(id)sender{
    ForgetPasswdViewController *vc = [CommonMethod getVCFromNib:[ForgetPasswdViewController class]];
    vc.phoneStr = self.mobileTextField.text;
    vc.isCodeLogin = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 重构
#pragma mark - Keyboard status
- (void)keyboardWillShowOrHide:(NSNotification *)notification {
//    NSDictionary *info = notification.userInfo;
//    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
//    CGRect keyboardEnd = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    CGFloat keyboardHeight = keyboardEnd.size.height;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(self.loginBtn.enabled){
        [self loginButtonClicked:self.loginBtn];
        return YES;
    }else{
        return NO;
    }
}

@end
