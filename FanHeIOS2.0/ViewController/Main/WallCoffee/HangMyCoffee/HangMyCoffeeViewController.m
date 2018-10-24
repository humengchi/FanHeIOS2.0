//
//  HangMyCoffeeViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/30.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "HangMyCoffeeViewController.h"

@interface HangMyCoffeeViewController ()<UITextViewDelegate>{
    NSInteger _maxCount;
}
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UILabel *statueLabel;
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

@end

@implementation HangMyCoffeeViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [CALayer updateControlLayer:self.inputTextView.layer radius:3 borderWidth:0.5 borderColor:kCellLineColor.CGColor];
    _maxCount = 50;
    [self.inputTextView becomeFirstResponder];
    __weak typeof(self) weakSelf = self;
    [self.inputTextView.rac_textSignal subscribeNext:^(NSString *text) {
        if(text.length > _maxCount-1){
            weakSelf.inputTextView.text = [text substringToIndex:_maxCount];
        }
        weakSelf.numberLabel.text = [NSString stringWithFormat:@"%ld/%ld", (unsigned long)weakSelf.inputTextView.text.length, (long)_maxCount];
        if(text.length == 0){
            weakSelf.sendBtn.enabled = NO;
            weakSelf.statueLabel.hidden = NO;
        }else{
            weakSelf.sendBtn.enabled = YES;
            weakSelf.statueLabel.hidden = YES;
        }
    }];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark- method
- (IBAction)backButtonClicked:(id)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendButtonClicked:(id)sender {
    [self.view endEditing:YES];
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"开启中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:self.inputTextView.text forKey:@"msg"];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:@"" forKey:@"headimg"];
    [requestDict setObject:@"" forKey:@"video"];
    [requestDict setObject:self.inputTextView.text forKey:@"remark"];
    [self requstType:RequestType_Post apiName:API_NAME_USER_SHOW_COFFEE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if(weakSelf.hangCoffeeSuccess){
                weakSelf.hangCoffeeSuccess();
            }
            [MBProgressHUD showSuccess:@"提交成功" toView:weakSelf.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            });
        }else{
            [MBProgressHUD showSuccess:@"提交失败" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark - Keyboard status
- (void)keyboardWillShowOrHide:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardEnd = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardEnd.size.height;
    [UIView animateWithDuration:duration animations:^{
        if([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
            self.view.frame = CGRectMake(0, 0, WIDTH, HEIGHT-keyboardHeight);
        }else{
            self.view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        }
    }];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]){
        if(self.sendBtn.isEnabled){
            [self sendButtonClicked:self.sendBtn];
        }
        return NO;
    }
    return YES;
}

@end
