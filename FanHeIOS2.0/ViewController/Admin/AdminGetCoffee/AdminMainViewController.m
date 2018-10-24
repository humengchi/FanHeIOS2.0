//
//  AdminMainViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/9/6.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "AdminMainViewController.h"
#import "AdminGetCoffeeViewController.h"
#import "AdminInputCodeViewController.h"
#import "ScanQRCodeViewController.h"
#import "WebViewController.h"

@interface AdminMainViewController ()<ScanQRCodeViewControllerDelegate>


@end

@implementation AdminMainViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(satrtReadButtonClicked:) name:@"satrtReadButtonClicked" object:nil];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - method
- (IBAction)satrtReadButtonClicked:(id)sender{
    [self newThreadForAvoidButtonRepeatClick:sender];
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if(granted){
            dispatch_async(dispatch_get_main_queue(), ^{
                ScanQRCodeViewController *vc = [[ScanQRCodeViewController alloc] init];
                vc.delegate = self;
                [self.navigationController pushViewController:vc animated:YES];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] setStatusBarHidden:NO];
            });
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"扫码需访问相机" message:@"请在iPhone的“设置>隐私>相机”选项中，允许3号圈访问你的相机" cancelButtonTitle:@"取消" otherButtonTitle:@"设置" cancle:^{
            } confirm:^{
                if(IOS_X >= 10){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }else{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy"]];
                }
            }];
        }
    }];
}

- (IBAction)inputCodeButtonClicked:(id)sender{
    AdminInputCodeViewController *vc = [CommonMethod getVCFromNib:[AdminInputCodeViewController class]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)logoutButtonClicked:(id)sender{
    [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"是否注销管理员账号？" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
        
    } confirm:^{
        [DataModelInstance shareInstance].adminUserModel = nil;
        [[AppDelegate shareInstance] gotoRegisterGuide];
    }];
}

#pragma mark - ScanQRCodeViewControllerDelegate
- (void)ScanQRCodeViewControllerDelegateResult:(NSString *)symbolsStr{
    if([symbolsStr hasPrefix:CoffeeQRCodeURL]){
        symbolsStr = [symbolsStr substringFromIndex:[CoffeeQRCodeURL length]];
    }else{
        if([CommonMethod paramStringIsNull:symbolsStr]){
            WebViewController *vc = [[WebViewController alloc] init];
            vc.webUrl = symbolsStr;
            vc.customTitle = @"详情";
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            [MBProgressHUD showError:@"无法识别二维码" toView:self.view];
        }
        return;
    }
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@", @(symbolsStr.integerValue)] forKey:@"param"];
    
    [self requstType:RequestType_Get apiName:API_NAME_USER_ADMIN_CK_COFFEE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            AdminGetCoffeeModel *model = [[AdminGetCoffeeModel alloc] initWithDict:responseObject[@"data"]];
            AdminGetCoffeeViewController *vc = [CommonMethod getVCFromNib:[AdminGetCoffeeViewController class]];
            vc.model = model;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }else{
            [MBProgressHUD showError:@"此咖啡无效" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

- (void)zbarDidStopWithError:(NSError *)error {
}

@end
