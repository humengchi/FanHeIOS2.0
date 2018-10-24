//
//  NotPassController.m
//  JinMai
//
//  Created by renhao on 16/5/14.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import "NotPassController.h"
#import "IdentityController.h"
#import "BaseTabbarViewController.h"

@interface NotPassController ()
@property (weak, nonatomic) IBOutlet UIButton *reviewBtn;
@property (weak, nonatomic) IBOutlet UILabel *reviewLabel;

@end

@implementation NotPassController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    if([self.rootTmpViewController isKindOfClass:[BaseTabbarViewController class]]){
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createrIDStart];
    self.view.backgroundColor = HEX_COLOR(@"F7F7F7");
    [self.reviewBtn.layer setMasksToBounds:YES];
    [self.reviewBtn.layer setCornerRadius:8.0]; //设置矩形四个圆角半径
    [self createrIdTabBerView];
}

- (void)createrIDStart{
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@",[DataModelInstance shareInstance].userModel.userId]forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_MEMBER_GET_IDENTITYSTART_MYSELF paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]==HttpResponseTypeSuccess){
            NSString *str = [CommonMethod paramStringIsNull:responseObject[@"data"][@"remark"]];
            NSString *text = [NSString stringWithFormat:@"由于%@，你的身份认证未通过！请重新修改名片信息，或者重新上传认证资料。",str];
            NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:text];
            [atr setAttributes:@{NSFontAttributeName:FONT_SYSTEM_SIZE(15), NSForegroundColorAttributeName:HEX_COLOR(@"8D96A7")} range:NSMakeRange(0, text.length)];
            NSRange range = [text rangeOfString:str];
            [atr setAttributes:@{NSFontAttributeName:FONT_SYSTEM_SIZE(15), NSForegroundColorAttributeName:kDefaultColor} range:range];
            self.reviewLabel.attributedText = atr;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        
    }];
}

#pragma mark -------  创建导航
- (void)createrIdTabBerView{
    UIView *tabBarView = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, 64) backColor:nil];
    tabBarView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tabBarView];
    UIButton *backBtn = [NSHelper createButton:CGRectMake(0,20 , 44, 44) title:nil unSelectImage:[UIImage imageNamed:@"btn_reture_white"] selectImage:nil target:self selector:@selector(backButtonClicked:)];
    [tabBarView addSubview:backBtn];
    UILabel *titleTabBaeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 26, WIDTH, 30)];
    titleTabBaeLabel.text = @"身份认证";
    titleTabBaeLabel.textColor = [UIColor whiteColor];
    titleTabBaeLabel.textAlignment = NSTextAlignmentCenter;
    [tabBarView addSubview:titleTabBaeLabel];
}

//返回
- (void)backButtonClicked:(id)sender {
    [self newThreadForAvoidButtonRepeatClick:sender];
    if(self.rootTmpViewController){
        [self.navigationController popToViewController:self.rootTmpViewController animated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)reviewBtnAction:(id)sender {
    [self newThreadForAvoidButtonRepeatClick:sender];
    IdentityController *vc = [[IdentityController alloc]init];
    vc.rootTmpViewController = self.rootTmpViewController;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
