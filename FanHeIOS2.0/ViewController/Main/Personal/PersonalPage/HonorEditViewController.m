//
//  HonorEditViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/19.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "HonorEditViewController.h"

@interface HonorEditViewController ()<UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIView *deleteView;
@property (nonatomic, weak) IBOutlet UIButton *sendbtn;
@property (nonatomic, weak) IBOutlet UITextField *contentTextField;

@end

@implementation HonorEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.model){
        self.deleteView.hidden = NO;
        self.contentTextField.text = self.model.honor;
        self.sendbtn.enabled = YES;
    }else{
        self.deleteView.hidden = YES;
        [self.contentTextField becomeFirstResponder];
    }
    self.view.backgroundColor = kTableViewBgColor;
    
    [self.contentTextField.subviews[0] removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - method
- (IBAction)navBackButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)publishButtonClicked:(id)sender{
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"保存中..." toView:self.view];
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:@(3) forKey:@"type"];
    [requestDict setObject:self.contentTextField.text forKey:@"tag"];
    if(self.model){
        [requestDict setObject:self.model.honorid forKey:@"honorid"];
    }
    [self requstType:RequestType_Post apiName:API_NAME_POST_USER_SETMYTAG paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"保存成功!" toView:weakSelf.view];
            HonorModel *honor = [[HonorModel alloc] initWithDict:responseObject[@"data"]];
            if(weakSelf.honorEditSuccess){
                if(weakSelf.model){
                    weakSelf.honorEditSuccess(HONOR_TYPE_EDIT, honor);
                }else{
                    weakSelf.honorEditSuccess(HONOR_TYPE_ADD, honor);
                }
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }else{
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

- (IBAction)deleteButtonClicked:(id)sender{
    [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"是否要删除该荣誉？" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
        
    } confirm:^{
        __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"删除中..." toView:self.view];
        __weak typeof(self) weakSelf = self;
        NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
        [requestDict setObject:[NSString stringWithFormat:@"/%@/%@", self.model.honorid,[DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
        [self requstType:RequestType_Delete apiName:API_NAME_DELETE_USER_DELHONOR paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
            [hud hideAnimated:YES];
            if([CommonMethod isHttpResponseSuccess:responseObject]){
                [MBProgressHUD showSuccess:@"删除成功!" toView:weakSelf.view];
                if(weakSelf.honorEditSuccess){
                    weakSelf.honorEditSuccess(HONOR_TYPE_DELETE, weakSelf.model);
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                });
            }else{
                [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
            [hud hideAnimated:YES];
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        }];
    }];
}

#pragma mark --UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    if(position && (range.length==0 || string.length==0)){
        return YES;
    }else{
        NSString *str = [textField.text stringByReplacingCharactersInRange:NSMakeRange(range.location, range.length) withString:string];
        if(str.length>20){
            self.contentTextField.text = [str substringToIndex:20];
            self.sendbtn.enabled = YES;
            return NO;
        }else{
            self.sendbtn.enabled = str.length>0;
        }
    }
    return YES;
}
@end
