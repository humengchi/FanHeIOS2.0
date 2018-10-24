//
//  LoginViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/6/21.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "LoginViewController.h"
#import "ForgetPasswdViewController.h"
#import "AccountDisabledView.h"

#define LOGIN_PHONE @"login_phone"

@interface LoginViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwdTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *mobileIsRightBtn;
@property (weak, nonatomic) IBOutlet UIButton *passwdIsRightBtn;
@property (weak, nonatomic) IBOutlet UILabel *mobileErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwdErrorLabel;
@property (nonatomic ,assign) CGFloat heigth;

@end

@implementation LoginViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //移除滑动手势
    for (UIGestureRecognizer *ges in self.view.gestureRecognizers){
        if([ges isKindOfClass:[UIPanGestureRecognizer class]]){
            [self.view removeGestureRecognizer:ges];
        }
    }
    NSString *phone = [CommonMethod paramStringIsNull:[[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_PHONE]];
    if(phone.length){
        self.mobileTextField.text = phone;
    }
    if(self.phoneStr.length){
        self.mobileTextField.text = self.phoneStr;
    }
    [self.mobileTextField becomeFirstResponder];
    [self.mobileTextField setValue:HEX_COLOR(@"AFB6C1") forKeyPath:@"_placeholderLabel.textColor"];
    [self.passwdTextField setValue:HEX_COLOR(@"AFB6C1") forKeyPath:@"_placeholderLabel.textColor"];
    __weak typeof(self) weakSelf = self;
    [self.mobileTextField.rac_textSignal subscribeNext:^(NSString *text) {
        weakSelf.mobileErrorLabel.hidden = YES;
        if(text.length > 11){
            weakSelf.mobileTextField.text = [text substringToIndex:11];
        }
        if(weakSelf.mobileTextField.text.length == 11){
            weakSelf.mobileIsRightBtn.hidden = NO;
            if([NSHelper justMobile:weakSelf.mobileTextField.text]){
                weakSelf.mobileIsRightBtn.selected = NO;
            }else{
                weakSelf.mobileIsRightBtn.selected = YES;
                weakSelf.mobileErrorLabel.hidden = NO;
                weakSelf.mobileErrorLabel.text = @"手机号格式有误";
            }
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
        if([NSHelper justMobile:text1] && text2.length >= 6){
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
    [requestDict setObject:self.mobileTextField.text forKey:@"phone"];
    [requestDict setObject:self.passwdTextField.text forKey:@"passwd"];
    
    [self requstType:RequestType_Post apiName:API_NAME_LOGIN_PASSWD paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        NSLog(@"%@",responseObject);
        [hud hideAnimated:YES];
        weakSelf.mobileErrorLabel.hidden = YES;
        weakSelf.mobileIsRightBtn.hidden = YES;
        weakSelf.passwdErrorLabel.hidden = YES;
        weakSelf.passwdIsRightBtn.hidden = YES;
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [[AppDelegate shareInstance] setZhugeTrack:@"帐号密码登录" properties:@{}];
            UserModel *model = [[UserModel alloc] initWithDict:[responseObject objectForKey:@"data"]];
            model.password = weakSelf.passwdTextField.text;
            [DataModelInstance shareInstance].userModel = model;
            [[AppDelegate shareInstance] updateWindowRootVC];
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
        }else if([[responseObject objectForKey:@"msg"] isEqualToString:@"你的账号存在问题，请联系客服021-65250669转823"]){
            AccountDisabledView *view = [CommonMethod getViewFromNib:@"AccountDisabledView"];
            view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
            [[UIApplication sharedApplication].keyWindow addSubview:view];
        }else{
            [MBProgressHUD showError:@"请求失败，请重试" toView:weakSelf.view];
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
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (self.passwdTextField == textField) {
        //回复动画
        if (WIDTH == 320) {
            [UIView animateWithDuration:0.5 animations:^{
                self.view.frame = CGRectMake(0, -self.heigth/2 , WIDTH, HEIGHT-self.heigth/2);
            }];
        }
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if (self.passwdTextField == textField) {
        self.view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    }
    return YES;
}
#pragma mark - 重构
#pragma mark - Keyboard status
- (void)keyboardWillShowOrHide:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
       CGRect keyboardEnd = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardEnd.size.height;
    self.heigth = keyboardHeight;
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
