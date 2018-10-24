//
//  CommentPersonController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/18.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "CommentPersonController.h"

@interface CommentPersonController ()<UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UIButton *sendbtn;
@property (nonatomic, weak) IBOutlet UILabel *realtionLabel;
@property (nonatomic, weak) IBOutlet UILabel *showLabel;
@property (nonatomic, weak) IBOutlet UITextView *contentTextView;
@property (nonatomic, weak) IBOutlet UILabel *placeholderLabel;
@property (nonatomic, weak) IBOutlet UILabel *numLabel;

@end

@implementation CommentPersonController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showLabel.text = [NSString stringWithFormat:@"请综合评价%@", self.realname];
    self.placeholderLabel.text = [NSString stringWithFormat:@"您可以从下面来评论%@\n1、人品、专长、优点、处事态度\n2、与他合作的感觉", self.realname];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - method
- (IBAction)sendButtonClicked:(id)sender{
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"发布中..." toView:self.view];
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.userId forKey:@"otherid"];
    [requestDict setObject:self.realtionLabel.text forKey:@"relation"];
    [requestDict setObject:self.contentTextView.text forKey:@"msg"];
    [self requstType:RequestType_Post apiName:API_NAME_POST_USER_EVALUATE_SMB paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"发布成功!" toView:weakSelf.view];
            if(weakSelf.commentSuccess){
                weakSelf.commentSuccess();
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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

- (IBAction)chooseRelationButtonClicked:(id)sender{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
    }];
    [cancelAction setValue:HEX_COLOR(@"41464e") forKey:@"_titleTextColor"];
    [alertController addAction:cancelAction];
    for(NSString *str in @[@"同事",@"前同事",@"同窗",@"合作伙伴",@"其他关系"]){
        UIAlertAction* alertAction = [UIAlertAction actionWithTitle:str style:UIAlertActionStyleDefault                                                                 handler:^(UIAlertAction * action) {
            self.realtionLabel.text = action.title;
            if(self.contentTextView.text.length>0){
                self.sendbtn.enabled = YES;
            }
        }];
        [alertAction setValue:HEX_COLOR(@"41464e") forKey:@"_titleTextColor"];
        [alertController addAction:alertAction];
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)backButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    }
    UITextRange *selectedRange = [textView markedTextRange];
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    if(position && (range.length==0 || text.length==0)){
        return YES;
    }else{
        NSString *str = [textView.text stringByReplacingCharactersInRange:NSMakeRange(range.location, range.length) withString:text];
        if(str.length>200){
            self.contentTextView.text = [str substringToIndex:200];
            self.numLabel.text = @"200/200";
            if(self.realtionLabel.text.length){
                self.sendbtn.enabled = str.length>0;
            }
            return NO;
        }else{
            self.numLabel.text = [NSString stringWithFormat:@"%lu/200", (unsigned long)str.length];
            if(self.realtionLabel.text.length){
                self.sendbtn.enabled = str.length>0;
            }
            self.placeholderLabel.hidden = str.length>0;
        }
    }
    return YES;
}

@end
