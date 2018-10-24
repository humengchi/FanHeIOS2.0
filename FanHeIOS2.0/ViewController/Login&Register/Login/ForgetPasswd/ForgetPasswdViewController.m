//
//  ForgetPasswdViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/1.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ForgetPasswdViewController.h"
#import "CheckCodeViewController.h"
#import "AccountDisabledView.h"

@interface ForgetPasswdViewController ()

@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIButton *mobileIsRightBtn;
@property (weak, nonatomic) IBOutlet UILabel *mobileErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *mainTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

@property (nonatomic, strong) NSDate *sendCodeDate;

@end

@implementation ForgetPasswdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //移除滑动手势
    for (UIGestureRecognizer *ges in self.view.gestureRecognizers){
        if([ges isKindOfClass:[UIPanGestureRecognizer class]]){
            [self.view removeGestureRecognizer:ges];
        }
    }
    if(self.phoneStr && self.phoneStr.length){
        self.mobileTextField.text = self.phoneStr;
    }
    if(self.isCodeLogin){
        self.mainTitleLabel.text = @"验证码登录";
        self.subTitleLabel.hidden = YES;
    }
    [self.mobileTextField becomeFirstResponder];
    [self.mobileTextField setValue:HEX_COLOR(@"AFB6C1") forKeyPath:@"_placeholderLabel.textColor"];
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
                weakSelf.nextBtn.enabled = YES;
            }else{
                weakSelf.mobileIsRightBtn.selected = YES;
                weakSelf.mobileErrorLabel.hidden = NO;
                weakSelf.mobileErrorLabel.text = @"手机号格式有误";
                weakSelf.nextBtn.enabled = NO;
            }
        }else{
            weakSelf.mobileIsRightBtn.hidden = YES;
            weakSelf.nextBtn.enabled = NO;
        }
    }];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(codeHasInValud) name:@"codeHasInValud" object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)codeHasInValud{
    self.sendCodeDate = nil;
}

#pragma mark - method
- (IBAction)sendCodeButtonClicked:(UIButton *)sender {
    [self.view endEditing:YES];
    if(self.sendCodeDate && [NSDate secondsAwayFrom:[NSDate date] dateSecond:self.sendCodeDate]<60 && [[DataModelInstance shareInstance].userModel.phone isEqualToString:self.mobileTextField.text]){
        CheckCodeViewController *vc = [CommonMethod getVCFromNib:[CheckCodeViewController class]];
        vc.phoneStr = self.mobileTextField.text;
        
        if(self.isCodeLogin){
            vc.codeType = Code_Type_Code_Login;
        }else{
            vc.codeType = Code_Type_Forget_Login;
        }
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@",self.mobileTextField.text] forKey:@"param"];
    
    UserModel *userModel = [DataModelInstance shareInstance].userModel;
    userModel.phone = self.mobileTextField.text;
    [DataModelInstance shareInstance].userModel = userModel;
    
    [self requstType:RequestType_Get apiName:API_NAME_SEND_VALID_CODE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            CheckCodeViewController *vc = [CommonMethod getVCFromNib:[CheckCodeViewController class]];
            vc.phoneStr = weakSelf.mobileTextField.text;
            if(weakSelf.isCodeLogin){
                vc.codeType = Code_Type_Code_Login;
            }else{
                vc.codeType = Code_Type_Forget_Login;
            }
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }else if([[responseObject objectForKey:@"msg"] isEqualToString:@"你的账号存在问题，请联系客服021-65250669转823"]){
            [weakSelf.view endEditing:YES];
            AccountDisabledView *view = [CommonMethod getViewFromNib:@"AccountDisabledView"];
            view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
            [[UIApplication sharedApplication].keyWindow addSubview:view];
        }else{
            [weakSelf.mobileTextField becomeFirstResponder];
            weakSelf.mobileErrorLabel.hidden = NO;
            weakSelf.mobileErrorLabel.text = @"该手机号未注册！";
            weakSelf.mobileIsRightBtn.selected = YES;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

- (IBAction)backNavButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
