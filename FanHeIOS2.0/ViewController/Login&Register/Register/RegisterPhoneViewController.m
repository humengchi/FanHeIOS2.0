//
//  RegisterPhoneViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/1.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "RegisterPhoneViewController.h"
#import "CheckCodeViewController.h"
#import "PolicyShowView.h"
#import "LoginViewController.h"

@interface RegisterPhoneViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIButton *inputIsRightBtn;
@property (weak, nonatomic) IBOutlet UILabel *showErrorLabel;

@property (weak, nonatomic) IBOutlet UIButton *readPolicyBtn;

@property (nonatomic, strong) NSDate *sendCodeDate;

@end

@implementation RegisterPhoneViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //移除滑动手势
    for (UIGestureRecognizer *ges in self.view.gestureRecognizers){
        if([ges isKindOfClass:[UIPanGestureRecognizer class]]){
            [self.view removeGestureRecognizer:ges];
        }
    }
    [self.textField becomeFirstResponder];
    [self.textField setValue:HEX_COLOR(@"AFB6C1") forKeyPath:@"_placeholderLabel.textColor"];
    __weak typeof(self) weakSelf = self;
    [self.textField.rac_textSignal subscribeNext:^(NSString *text) {
        weakSelf.showErrorLabel.hidden = YES;
        if(text.length > 11){
            weakSelf.textField.text = [text substringToIndex:11];
        }
        if(weakSelf.textField.text.length == 11){
            weakSelf.inputIsRightBtn.hidden = NO;
            if([NSHelper justMobile:weakSelf.textField.text]){
                weakSelf.inputIsRightBtn.selected = NO;
                weakSelf.nextBtn.enabled = YES;
            }else{
                weakSelf.inputIsRightBtn.selected = YES;
                weakSelf.showErrorLabel.hidden = NO;
                weakSelf.showErrorLabel.text = @"手机号格式有误";
                weakSelf.nextBtn.enabled = NO;
            }
        }else{
            weakSelf.inputIsRightBtn.hidden = YES;
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
- (IBAction)backNavButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)nextButtonClicked:(UIButton *)sender {
    [self.view endEditing:YES];
    if(self.sendCodeDate && [NSDate secondsAwayFrom:[NSDate date] dateSecond:self.sendCodeDate]<60 && [[DataModelInstance shareInstance].userModel.phone isEqualToString:self.textField.text]){
        CheckCodeViewController *vc = [CommonMethod getVCFromNib:[CheckCodeViewController class]];
        vc.phoneStr = self.textField.text;
        vc.codeType = Code_Type_Register;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@",self.textField.text] forKey:@"param"];
    
    UserModel *userModel = [DataModelInstance shareInstance].userModel;
    userModel.phone = self.textField.text;
    [DataModelInstance shareInstance].userModel = userModel;
    
    [self requstType:RequestType_Get apiName:API_NAME_REGISTER_PHONE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [DataModelInstance shareInstance].userModel.phone = weakSelf.textField.text;
            weakSelf.sendCodeDate = [NSDate date];
            CheckCodeViewController *vc = [CommonMethod getVCFromNib:[CheckCodeViewController class]];
            vc.phoneStr = weakSelf.textField.text;
            vc.codeType = Code_Type_Register;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }else{
            [weakSelf.textField becomeFirstResponder];
            weakSelf.showErrorLabel.hidden = NO;
            weakSelf.showErrorLabel.text = @"该手机号已注册！";
            weakSelf.inputIsRightBtn.selected = YES;
            [[[CommonUIAlert alloc] init] showCommonAlertView:weakSelf title:@"" message:@"该手机号已注册" cancelButtonTitle:@"取消" otherButtonTitle:@"登录" cancle:^{
            } confirm:^{
                LoginViewController *vc = [CommonMethod getVCFromNib:[LoginViewController class]];
                vc.phoneStr = weakSelf.textField.text;
                [weakSelf.navigationController setViewControllers:@[self.navigationController.viewControllers.firstObject, vc] animated:YES];
            }];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

- (IBAction)readPolicyButtonClicked:(UIButton *)sender {
    [self.view endEditing:YES];
    PolicyShowView *view = [CommonMethod getViewFromNib:NSStringFromClass([PolicyShowView class])];
    view.frame = CGRectMake(0, HEIGHT, WIDTH, HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    [UIView animateWithDuration:0.5 animations:^{
        view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    }];
    /*
    sender.selected = !sender.selected;
    if(sender.selected){
        [self.view endEditing:YES];
        PolicyShowView *view = [CommonMethod getViewFromNib:NSStringFromClass([PolicyShowView class])];
        view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    }
    if(self.readPolicyBtn.selected && self.inputIsRightBtn.hidden == NO && self.inputIsRightBtn.isSelected == NO){
        self.nextBtn.enabled = YES;
    }else{
        self.nextBtn.enabled = NO;
    }*/
}

@end
