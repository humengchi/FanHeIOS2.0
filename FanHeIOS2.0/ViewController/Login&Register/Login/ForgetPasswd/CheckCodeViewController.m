//
//  CheckCodeViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/1.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "CheckCodeViewController.h"
#import "ModifyPasswdViewController.h"
#import "AccountViewController.h"
#import "AccountDisabledView.h"
#define RepeatSec 59

@interface CheckCodeViewController ()<UITextFieldDelegate>{
    NSDate * goBackgroundDate;
    NSString *_tmpCodeStr;
}


@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UIButton *timeBtn;
@property (weak, nonatomic) IBOutlet UILabel *mobileDisplayLabel;
@property (weak, nonatomic) IBOutlet UIButton *codeIsRightBtn;
@property (weak, nonatomic) IBOutlet UILabel *codeErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *sendAudioCodeLabel;


@property (nonatomic, strong) NSTimer  *timer;
@property (nonatomic, assign) NSInteger repeatSecond;

@end

@implementation CheckCodeViewController

//循环方法
- (void)timerSelector{
    if(self.repeatSecond-- > 1){
        [UIView setAnimationsEnabled:NO];
        [self.timeBtn setTitle:[NSString stringWithFormat:@"%lds", (long)self.repeatSecond] forState:UIControlStateNormal];
        self.timeBtn.userInteractionEnabled = NO;
        self.timeBtn.selected = NO;
    }else{
        [UIView setAnimationsEnabled:YES];
        self.timeBtn.userInteractionEnabled = YES;
        self.timeBtn.selected = YES;
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc]initWithString:@"收不到短信，您可语音获取"];
        [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"2980B9"] range:NSMakeRange(8, 4)];
        self.sendAudioCodeLabel.attributedText = attributedStr;
        self.sendAudioCodeLabel.userInteractionEnabled = YES;
        self.repeatSecond = RepeatSec;
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerSelector) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appGoBackgroud) name:@"applicationWillResignActive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appGoForegroud) name:@"applicationDidBecomeActive" object:nil];
}

- (void)appGoBackgroud{
    goBackgroundDate = [NSDate date];
}

- (void)appGoForegroud{
    NSTimeInterval timeGone = [[NSDate date]timeIntervalSinceDate:goBackgroundDate];
    self.repeatSecond -= timeGone;
    [self timerSelector];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //移除滑动手势
    for (UIPanGestureRecognizer *ges in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:ges];
    }
    [self removeViewTapGesture];
    self.repeatSecond = RepeatSec;
    
    [CommonMethod viewAddGuestureRecognizer:self.sendAudioCodeLabel tapsNumber:1 withTarget:self withSEL:@selector(sendAudioCode)];
    self.mobileDisplayLabel.text = [NSString stringWithFormat:@"验证码已发送到手机：%@", self.phoneStr];
    [self.codeTextField becomeFirstResponder];
    [self.codeTextField setValue:HEX_COLOR(@"AFB6C1") forKeyPath:@"_placeholderLabel.textColor"];
    __weak typeof(self) weakSelf = self;
    [self.codeTextField.rac_textSignal subscribeNext:^(NSString *text) {
        if(text.length > 4){
            weakSelf.codeTextField.text = [text substringToIndex:4];
            weakSelf.codeErrorLabel.hidden = YES;
        }
        if(weakSelf.codeTextField.text.length == 4){
            if(_tmpCodeStr && [weakSelf.codeTextField.text isEqualToString:_tmpCodeStr]){
                return;
            }
            _tmpCodeStr = weakSelf.codeTextField.text;
            if(weakSelf.codeType == Code_Type_Code_Login){
                [weakSelf loginCode];
            }else{
                [weakSelf checkValidCode];
            }
        }else{
            _tmpCodeStr = weakSelf.codeTextField.text;
            weakSelf.codeErrorLabel.hidden = YES;
            weakSelf.codeIsRightBtn.hidden = YES;
        }
    }];

    // Do any additional setup after loading the view from its nib.
}

#pragma mark - method
- (IBAction)backNavButtonClicked:(id)sender{
    __weak typeof(self) weakSelf = self;
    [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"验证码短信可能略有延迟，确认返回并重新开始？" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
        
    } confirm:^{
        [UIView setAnimationsEnabled:YES];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
}

//语音验证码
- (void)sendAudioCode{
    self.sendAudioCodeLabel.text = @"“3号圈”将拨打您的手机告知动态码";
    self.sendAudioCodeLabel.userInteractionEnabled = NO;
    self.repeatSecond = RepeatSec;
    [self.timer invalidate];
    self.timer = nil;
    self.timeBtn.selected = NO;
    [self.timeBtn setTitle:@"59s" forState:UIControlStateNormal];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerSelector) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@",self.phoneStr] forKey:@"param"];
    NSString *apiStr;
    apiStr = API_NAME_SEND_AUDIO_VALID_CODE;
    [self requstType:RequestType_Get apiName:apiStr paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
        }else{
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

- (IBAction)sendCodeButtonClicked:(UIButton *)sender {
    self.timeBtn.selected = NO;
    [self.timeBtn setTitle:@"59s" forState:UIControlStateNormal];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerSelector) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@",self.phoneStr] forKey:@"param"];
    NSString *apiStr;
    if(self.codeType == Code_Type_Register){
        apiStr = API_NAME_REGISTER_PHONE;
    }else{
        apiStr = API_NAME_SEND_VALID_CODE;
    }
    [self requstType:RequestType_Get apiName:apiStr paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
        }else{
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

#pragma mark - 网络请求，检查验证码是否正确
- (void)checkValidCode{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"验证中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@",self.phoneStr, self.codeTextField.text] forKey:@"param"];
    
    [self requstType:RequestType_Get apiName:API_NAME_CHECK_VALID_CODE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if (self.typeIndex == 1) {
                UserModel *tmpModel = [DataModelInstance shareInstance].userModel;
                tmpModel.phone = weakSelf.phoneStr;
                [DataModelInstance shareInstance].userModel = tmpModel;
                [MBProgressHUD showSuccess:@"手机号修改成功" toView:self.view];
                UIViewController *vc = weakSelf.navigationController.viewControllers[weakSelf.navigationController.viewControllers.count-4];
                [weakSelf.navigationController popToViewController:vc animated:YES];
                [weakSelf.view endEditing:YES];
                return ;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"codeHasInValud" object:nil];
            weakSelf.repeatSecond = 0;
            weakSelf.codeIsRightBtn.hidden = YES;
            weakSelf.codeIsRightBtn.selected = NO;
            weakSelf.codeErrorLabel.hidden = YES;
           
            ModifyPasswdViewController *vc = [CommonMethod getVCFromNib:[ModifyPasswdViewController class]];
            if (self.typeIndex == 2) {
                vc.typeIndex = weakSelf.typeIndex;
            }
            vc.phoneStr = weakSelf.phoneStr;
            vc.codeType = weakSelf.codeType;
            [weakSelf.navigationController pushViewController:vc animated:YES];
            [weakSelf.view endEditing:YES];
        }else{
            weakSelf.codeErrorLabel.hidden = NO;
            weakSelf.codeIsRightBtn.hidden = NO;
            weakSelf.codeIsRightBtn.selected = YES;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

- (void)loginCode{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"验证中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:self.codeTextField.text forKey:@"code"];
    [requestDict setObject:self.phoneStr forKey:@"phone"];
    
    [self requstType:RequestType_Post apiName:API_NAME_LOGIN_CODE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [[AppDelegate shareInstance] setZhugeTrack:@"验证码登录" properties:@{}];
            [DataModelInstance shareInstance].userModel = [[UserModel alloc] initWithDict:[responseObject objectForKey:@"data"]];
            [weakSelf.view endEditing:YES];
            ModifyPasswdViewController *vc = [CommonMethod getVCFromNib:[ModifyPasswdViewController class]];
            vc.codeType = Code_Type_Code_Login;
            vc.phoneStr = weakSelf.phoneStr;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }else if([[responseObject objectForKey:@"msg"] isEqualToString:@"你的账号存在问题，请联系客服021-65250669转823"]){
            [weakSelf.view endEditing:YES];
            weakSelf.codeErrorLabel.hidden = YES;
            weakSelf.codeIsRightBtn.hidden = YES;
            AccountDisabledView *view = [CommonMethod getViewFromNib:@"AccountDisabledView"];
            view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
            [[UIApplication sharedApplication].keyWindow addSubview:view];
        }else{
            weakSelf.codeErrorLabel.hidden = NO;
            weakSelf.codeIsRightBtn.hidden = NO;
            weakSelf.codeIsRightBtn.selected = YES;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(self.codeTextField.text.length == 4){
        if(self.codeType == Code_Type_Code_Login){
            [self loginCode];
        }else{
            [self checkValidCode];
        }
    }
    return YES;
}

@end
