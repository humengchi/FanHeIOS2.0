 
//
//  ChangeFillPhoneController.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/31.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ChangeFillPhoneController.h"
#import "CheckCodeViewController.h"
@interface ChangeFillPhoneController ()
@property (weak, nonatomic) IBOutlet UILabel *phoneShowText;
@property (weak, nonatomic) IBOutlet UILabel *passShowLabel;
@property (weak, nonatomic) IBOutlet UIButton *mobileIsRightBtn;
@property (weak, nonatomic) IBOutlet UILabel *mobileErrorLabel;
@property (weak, nonatomic) IBOutlet UITextField *PhoneText;

@end

@implementation ChangeFillPhoneController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.typeIndex == 1) {
        self.phoneShowText.text = @"下次登录可使用新手机号登录";
        self.passShowLabel.text = @"修改手机号";
    }else{
        self.PhoneText.text = [DataModelInstance shareInstance].userModel.phone;
        [self.PhoneText setEnabled:NO];
    }
    
    [self.PhoneText becomeFirstResponder];
    [self.PhoneText setValue:HEX_COLOR(@"AFB6C1") forKeyPath:@"_placeholderLabel.textColor"];
    __weak typeof(self) weakSelf = self;
    [self.PhoneText.rac_textSignal subscribeNext:^(NSString *text) {
        weakSelf.mobileErrorLabel.hidden = YES;
        if(text.length > 11){
            weakSelf.PhoneText.text = [text substringToIndex:11];
        }
        if(weakSelf.PhoneText.text.length == 11){
            weakSelf.mobileIsRightBtn.hidden = NO;
            if([NSHelper justMobile:weakSelf.PhoneText.text]){
                weakSelf.mobileIsRightBtn.selected = NO;
                weakSelf.getCode.enabled = YES;
            }else{
                weakSelf.mobileIsRightBtn.selected = YES;
                weakSelf.mobileErrorLabel.hidden = NO;
                weakSelf.mobileErrorLabel.text = @"手机号格式有误";
                weakSelf.getCode.enabled = NO;
            }
        }else{
            weakSelf.mobileIsRightBtn.hidden = YES;
            weakSelf.getCode.enabled = NO;
        }
    }];
}

- (IBAction)getCodeAction:(UIButton *)sender {
    [self.view endEditing:YES];
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@",self.PhoneText.text] forKey:@"param"];
    NSString *api = API_NAME_SEND_VALID_CODE;
    if (self.typeIndex == 1) {
     //修改手机号
        api = API_NAME_REGISTER_PHONE;
    }
    [self requstType:RequestType_Get apiName:api paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            CheckCodeViewController *vc = [CommonMethod getVCFromNib:[CheckCodeViewController class]];
            vc.phoneStr = weakSelf.PhoneText.text;
            vc.codeType = Code_Type_Forget_Login;
            if (self.typeIndex == 2) {
                //修改密码
                 vc.typeIndex = 2;
            }else{
                //修改手机号
                vc.typeIndex = 1;
            }
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }else{
            [MBProgressHUD showError:responseObject[@"msg"] toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];

}

- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
