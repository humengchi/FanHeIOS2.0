//
//  AdminInputCodeDetailViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/9/14.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "AdminInputCodeDetailViewController.h"
#import "AdminGetCoffeeResultViewController.h"

@interface AdminInputCodeDetailViewController ()

@property (nonatomic, weak) IBOutlet UILabel *codeKeyLabel;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *statueLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;
@property (nonatomic, weak) IBOutlet UIButton *getBtn;

@end

@implementation AdminInputCodeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *newString = @"";
    NSString *text = [CommonMethod paramStringIsNull:self.model.cdkey];
    while (text.length > 0) {
        NSString *subString = [text substringToIndex:MIN(text.length, 3)];
        newString = [newString stringByAppendingString:subString];
        if (subString.length == 3) {
            newString = [newString stringByAppendingString:@" "];
        }
        text = [text substringFromIndex:MIN(text.length, 3)];
    }
    self.codeKeyLabel.text = newString;
    self.usernameLabel.text = [CommonMethod paramStringIsNull:self.model.username];
    if(self.model.status.integerValue == 0){
        self.statueLabel.text = @"未使用";
        self.statueLabel.textColor = HEX_COLOR(@"38B315");
        self.getBtn.hidden = NO;
    }else if(self.model.status.integerValue == 1){
        self.statueLabel.text = @"已使用";
        self.statueLabel.textColor = HEX_COLOR(@"A81F09");
    }else{
        self.statueLabel.text = @"已过期";
        self.statueLabel.textColor = HEX_COLOR(@"A81F09");
    }
    self.detailLabel.text = self.model.remark;
}

#pragma mark -
- (IBAction)backNavButtonClicked:(id)sender{
    if(self.model.status.integerValue){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)methodButtonClicked:(id)sender{
    __weak typeof(self) weakSelf = self;
    [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"是否确认兑换？" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
        
    } confirm:^{
        [weakSelf getCoffeeHttp];
    }];
}

#pragma mark - 网络请求
- (void)getCoffeeHttp{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"处理中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:self.model.cdkey forKey:@"cdkey"];
    
    [self requstType:RequestType_Post apiName:API_NAME_USER_ADMIN_USE_CD_KEY paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            AdminGetCoffeeResultViewController *vc = [CommonMethod getVCFromNib:[AdminGetCoffeeResultViewController class]];
            vc.resultType = Result_Type_GetCoffee;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }else{
            [MBProgressHUD showError:@"兑换失败，请重试" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

@end
