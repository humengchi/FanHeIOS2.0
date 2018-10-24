//
//  ModifyPasswdViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/1.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ModifyPasswdViewController.h"

@interface ModifyPasswdViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *passwdTextField;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIButton *passwdIsRightBtn;
@property (weak, nonatomic) IBOutlet UILabel *passwdErrorLabel;
@property (weak, nonatomic) IBOutlet UIButton *passBtn;//跳过
@property (weak, nonatomic) IBOutlet UIButton *gotoHomeBtn;//进入金脉,修改密码
@end

@implementation ModifyPasswdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //移除滑动手势
    for (UIGestureRecognizer *ges in self.view.gestureRecognizers){
        if([ges isKindOfClass:[UIPanGestureRecognizer class]]){
            [self.view removeGestureRecognizer:ges];
        }
    }
    [self.passwdTextField becomeFirstResponder];
    [self.passwdTextField setValue:HEX_COLOR(@"AFB6C1") forKeyPath:@"_placeholderLabel.textColor"];
    __weak typeof(self) weakSelf = self;
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
                weakSelf.nextBtn.enabled = YES;
                weakSelf.gotoHomeBtn.enabled = YES;
            }else{
                weakSelf.passwdIsRightBtn.selected = YES;
                weakSelf.passwdErrorLabel.hidden = NO;
                weakSelf.passwdErrorLabel.text = @"密码为6~20个字符";
                weakSelf.passwdTextField.text = [text substringToIndex:20];
                weakSelf.nextBtn.enabled = YES;
                weakSelf.gotoHomeBtn.enabled = YES;
            }
        }else{
            weakSelf.passwdIsRightBtn.hidden = YES;
            weakSelf.nextBtn.enabled = NO;
            weakSelf.gotoHomeBtn.enabled = NO;
        }
    }];
    if(self.codeType == Code_Type_Code_Login){
        self.backNavBtn.hidden = YES;
        self.passBtn.hidden = NO;
        self.gotoHomeBtn.hidden = NO;
        self.nextBtn.hidden = YES;
        [CALayer updateControlLayer:self.gotoHomeBtn.layer radius:5 borderWidth:0 borderColor:nil];
        [self.gotoHomeBtn setBackgroundImage:[kImageWithName(@"btn_rm_off_red") imageWithColor:HEX_COLOR(@"d7d7d7")] forState:UIControlStateDisabled];
    }
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - method
- (IBAction)backNavButtonClicked:(id)sender{
    NSMutableArray *vcArray = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
    [vcArray removeLastObject];
    [vcArray removeLastObject];
    [self.navigationController setViewControllers:vcArray animated:YES];
}

- (IBAction)modifyPasswdButtonClicked:(UIButton *)sender {
    [self.view endEditing:YES];
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:self.phoneStr forKey:@"phone"];
    [requestDict setObject:self.passwdTextField.text forKey:@"passwd"];
    NSString *apiStr = @"";
    if(self.codeType == Code_Type_Register){
        apiStr = API_NAME_REGISTER;
        [requestDict setObject:[DataModelInstance shareInstance].userModel.realname forKey:@"name"];
    }else{
        apiStr = API_NAME_RESET_PASSWD;
    }
    
    [self requstType:RequestType_Post apiName:apiStr paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            UserModel *userModel = [DataModelInstance shareInstance].userModel;
            userModel.password = weakSelf.passwdTextField.text;
            if(self.codeType == Code_Type_Register){
                userModel.userId = [CommonMethod paramNumberIsNull:responseObject[@"data"]];
            }
            [DataModelInstance shareInstance].userModel = userModel;
            
            if (self.typeIndex == 2) {
                [[AppDelegate shareInstance] setZhugeTrack:@"设置中密码修改" properties:@{}];
                [MBProgressHUD showSuccess:@"密码修改成功" toView:self.view];
                UIViewController *vc = weakSelf.navigationController.viewControllers[weakSelf.navigationController.viewControllers.count-4];
                [weakSelf.navigationController popToViewController:vc animated:YES];
                return ;
            }
            if(weakSelf.codeType == Code_Type_Code_Login){
                [[AppDelegate shareInstance] setZhugeTrack:@"验证码登录中密码修改" properties:@{}];
                [MBProgressHUD showSuccess:@"密码保存成功" toView:weakSelf.view];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[AppDelegate shareInstance] updateWindowRootVC];
                });
            }else if(weakSelf.codeType == Code_Type_Forget_Login){
                [[AppDelegate shareInstance] setZhugeTrack:@"忘记密码中密码修改" properties:@{}];
                [MBProgressHUD showSuccess:@"修改密码成功" toView:weakSelf.view];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSArray *vcArray = weakSelf.navigationController.viewControllers;
                    [weakSelf.navigationController setViewControllers:@[vcArray[0], vcArray[1]] animated:YES];
                });
            }else{
                [[AppDelegate shareInstance] setZhugeTrack:@"帐号注册成功" properties:@{}];
                [MBProgressHUD showSuccess:@"恭喜你！注册成功" toView:weakSelf.view];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    [[AppDelegate shareInstance] gotoRecommendContacts];
                    [[AppDelegate shareInstance] gotoScanCard];
                });
            }
        }else{
            [MBProgressHUD showError:[responseObject objectForKey:@"msg"] toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark - 跳过
- (IBAction)passButtonClicekd:(id)sender{
    [[AppDelegate shareInstance] updateWindowRootVC];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(self.nextBtn.enabled || self.gotoHomeBtn.enabled){
        [self modifyPasswdButtonClicked:self.nextBtn];
    }
    return YES;
}

@end
