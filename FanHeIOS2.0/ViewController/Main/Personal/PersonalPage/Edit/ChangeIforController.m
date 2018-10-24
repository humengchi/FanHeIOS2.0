//
//  ChangeIforController.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/11/4.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ChangeIforController.h"

@interface ChangeIforController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textFileInfore;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (nonatomic, strong) UserModel *userModel;

@end

@implementation ChangeIforController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textFileInfore.delegate = self;
    self.userModel = [DataModelInstance shareInstance].userModel;
    self.view.backgroundColor = [UIColor colorWithHexString:@"EFEFF4"];
    self.titleLabel.text = self.titleStr;
    //设置边框样式，只有设置了才会显示边框样式
    
    [self.textFileInfore becomeFirstResponder];
    self.textFileInfore.borderStyle = UITextBorderStyleNone;
    self.textFileInfore.returnKeyType = UIReturnKeyDone;
    if (self.index == 5) {
        if (self.userModel.realname.length > 0) {
            self.textFileInfore.text = self.userModel.realname;
        }
    }
    if (self.index == 7) {
        if (self.userModel.email.length > 0) {
            self.textFileInfore.text = self.userModel.email;
        }
    }
    if (self.index == 8){
        if (self.userModel.weixin.length > 0) {
            self.textFileInfore.text = self.userModel.weixin;
        }
    }
    self.textFileInfore.placeholder = [NSString stringWithFormat:@"请输入%@",self.titleStr];
    self.saveBtn.enabled = self.textFileInfore.text.length>0;
}

- (IBAction)saverAction:(UIButton *)sender {
    [self.textFileInfore resignFirstResponder];
    if (self.index == 5) {
        if([self.textFileInfore.text isEqualToString:[DataModelInstance shareInstance].userModel.realname]){
            [self dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        if(self.userModel.hasValidUser.integerValue == 1) {
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"你修改了关键信息，需重新申请认证。是否需要修改？" cancelButtonTitle:@"确定" otherButtonTitle:@"取消" cancle:^{
                [self postChangeMyMessage];
            } confirm:^{
            }];
            return;
        }else{
            [self postChangeMyMessage];
        }
    }else if (self.index == 7) {
        if (![NSHelper justEmail:self.textFileInfore.text]) {
            [self showHint:@"请输入正确邮箱"];
            return;
        }else{
            [self postChangeMyMessage];
        }
    }else if (self.index == 8){
        [self postChangeMyMessage];
    }
}

- (void)postChangeMyMessage{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:self.userModel.userId forKey:@"userid"];
    /*
     5 ----- 姓名
     7 －－－ 邮箱号
     8 －－－微信号
     */
    if (self.index == 5) {
        if ([NSHelper justChinessAndEnlish:self.textFileInfore.text]) {
            [requestDict setObject:self.textFileInfore.text forKey:@"realname"];
            self.userModel.realname = self.textFileInfore.text;
        }else{
            [self showHint:@"姓名只能输入中英文"];
            return;
        }
    }else if (self.index == 7) {
        [requestDict setObject:self.textFileInfore.text forKey:@"email"];
        self.userModel.email = self.textFileInfore.text;
    }else if (self.index == 8){
        [requestDict setObject:self.textFileInfore.text forKey:@"weixin"];
        self.userModel.weixin = self.textFileInfore.text;
    }
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"保存中..." toView:self.view];
    [self requstType:RequestType_Post apiName:API_NAME_SAVE_MY_INFO paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if (weakSelf.changeDelegate && [weakSelf.changeDelegate respondsToSelector:@selector(changeMyMessage:)]) {
                [weakSelf.changeDelegate changeMyMessage:weakSelf.textFileInfore.text];
                if (self.index == 5) {
                    if (self.userModel.hasValidUser.integerValue == 1) {
                        self.userModel.hasValidUser = [NSNumber numberWithInt:0];
                    }
                }
                [DataModelInstance shareInstance].userModel = self.userModel;
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

- (IBAction)goBack:(UITapGestureRecognizer *)sender {
    [self.textFileInfore resignFirstResponder];
    if (self.index == 5) {
        if (![self.userModel.realname isEqualToString:self.textFileInfore.text]) {
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"是否放弃编辑资料？" cancelButtonTitle:@"放弃" otherButtonTitle:@"继续编辑" cancle:^{
                [self dismissViewControllerAnimated:YES completion:nil];
            } confirm:^{
            }];
        }else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }else if (self.index == 7) {
        if (![self.userModel.email isEqualToString:self.textFileInfore.text]) {
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"是否放弃编辑资料？" cancelButtonTitle:@"放弃" otherButtonTitle:@"继续编辑" cancle:^{
                [self dismissViewControllerAnimated:YES completion:nil];
            } confirm:^{
            }];
        }else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }else if (self.index == 8){
        if (![self.userModel.weixin isEqualToString:self.textFileInfore.text]) {
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"是否放弃编辑资料？" cancelButtonTitle:@"放弃" otherButtonTitle:@"继续编辑" cancle:^{
                [self dismissViewControllerAnimated:YES completion:nil];
            } confirm:^{
            }];
        }else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark -UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.text.length == 0) {
        NSString *tem = [[string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]componentsJoinedByString:@""];
        if (![string isEqualToString:tem]) {
            return NO;
        }
    }
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    if(position && (range.length==0 || string.length==0)){
        return YES;
    }else{
        NSString *str = [textField.text stringByReplacingCharactersInRange:NSMakeRange(range.location, range.length) withString:string];
        self.saveBtn.enabled = str.length>0;
        if (self.index == 5) {
            if(str.length>10){
                self.textFileInfore.text = [str substringToIndex:10];
                return NO;
            }
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)textFileBecomeReig:(UITapGestureRecognizer *)sender {
    [self.textFileInfore becomeFirstResponder];
}

@end
