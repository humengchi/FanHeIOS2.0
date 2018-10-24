//
//  AdminInputCodeViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/9/14.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "AdminInputCodeViewController.h"
#import "AdminInputCodeDetailViewController.h"

@interface AdminInputCodeViewController ()<UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIButton *nextBtn;
@property (nonatomic, weak) IBOutlet UITextField *textField;

@end

@implementation AdminInputCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.textField becomeFirstResponder];
    [self.textField.rac_textSignal subscribeNext:^(NSString *text) {
        if(text.length){
            self.nextBtn.enabled = YES;
        }else{
            self.nextBtn.enabled = NO;
        }
    }];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - method
- (IBAction)gotoDetail:(id)sender{
    if(self.textField.text.length){
        [self getCoffeeCodeDetailHttp];
    }
}

- (IBAction)backNavButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 网络请求
- (void)getCoffeeCodeDetailHttp{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    NSString *
    text = [self.textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    [requestDict setObject:[NSString stringWithFormat:@"/%@",text] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_USER_ADMIN_GET_CD_KEY_INFO paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            AdminCodeKeyModel *model = [[AdminCodeKeyModel alloc] initWithDict:responseObject[@"data"]];
            AdminInputCodeDetailViewController *vc = [CommonMethod getVCFromNib:[AdminInputCodeDetailViewController class]];
            vc.model = model;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }else{
            [MBProgressHUD showError:@"兑换码无效" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSString *
    text = [self.textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(text.length){
        [self gotoDetail:nil];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = [textField text];
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789\b"];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([string rangeOfCharacterFromSet:[characterSet invertedSet]].location != NSNotFound) {
        return NO;
    }
    
    text = [text stringByReplacingCharactersInRange:range withString:string];
    text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];

    // 如果是电话号码格式化，需要添加这三行代码
//    NSMutableString *temString = [NSMutableString stringWithString:text];
//    [temString insertString:@" " atIndex:0];
//    text = temString;
    
    NSString *newString = @"";
    while (text.length > 0) {
        NSString *subString = [text substringToIndex:MIN(text.length, 3)];
        newString = [newString stringByAppendingString:subString];
        if (subString.length == 3) {
            newString = [newString stringByAppendingString:@" "];
        }
        text = [text substringFromIndex:MIN(text.length, 3)];
    }
    
    newString = [newString stringByTrimmingCharactersInSet:[characterSet invertedSet]];
    if (newString.length >= 100) {
        return NO;
    }
    [textField setText:newString];
    
    return NO;
}

@end
