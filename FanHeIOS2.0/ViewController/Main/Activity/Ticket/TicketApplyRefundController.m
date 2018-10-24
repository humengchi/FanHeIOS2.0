//
//  TicketApplyRefundController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/6/8.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "TicketApplyRefundController.h"

@interface TicketApplyRefundController ()<UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UIButton *nextBtn;
@property (nonatomic, weak) IBOutlet UITextView *inputTextView;
@property (nonatomic, weak) IBOutlet UILabel *numLabel;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end

@implementation TicketApplyRefundController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kTableViewBgColor;
    if(self.amount.floatValue > 0){
        self.titleLabel.text = @"申请退票";
    }else{
        self.titleLabel.text = @"取消报名";
    }
}

#pragma mark - method
- (IBAction)backButtonclicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)nextButtonClicked:(id)sender{
    if([NSDate secondsAwayFrom:[NSDate date] dateSecond:self.startDate] > 0 || [NSDate secondsAwayFrom:self.startDate dateSecond:[NSDate date]] < 24*60*60){
        [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"活动即将开始，已无法退票" cancelButtonTitle:nil otherButtonTitle:@"确定" cancle:nil confirm:^{
            
        }];
    }else{
        [self loadHttpData];
    }
}

- (IBAction)chooseButtonClicked:(UIButton*)sender{
    self.inputTextView.text = [sender.titleLabel.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.nextBtn.enabled = YES;
}

#pragma mark - 网络请求
- (void)loadHttpData{
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.ordernum forKey:@"ordernum"];
    [requestDict setObject:self.inputTextView.text forKey:@"remark"];
    [self requstType:RequestType_Post apiName:API_NAME_POST_ACTIVITY_CANCLE_APPLY paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"提交成功" toView:weakSelf.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }else{
            [MBProgressHUD showError:[CommonMethod paramStringIsNull:responseObject[@"msg"]] toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络设置" toView:weakSelf.view];
    }];
}

#pragma mark - UITextViewDelegate
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
        if(str.length>140){
            self.inputTextView.text = [str substringToIndex:140];
            self.numLabel.text = [NSString stringWithFormat:@"%ld/140", textView.text.length];
            return NO;
        }else{
            self.numLabel.text = [NSString stringWithFormat:@"%ld/140", str.length];
        }
        self.nextBtn.enabled = str.length>0;
    }
    return YES;
}


@end
