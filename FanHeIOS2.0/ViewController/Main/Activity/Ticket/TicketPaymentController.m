//
//  TicketPaymentController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/6/8.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "TicketPaymentController.h"
#import "ApplySucceedController.h"
#import "ActivityDetailController.h"
#import "MyActivityOrderController.h"

@interface TicketPaymentController ()<WXApiDelegate>{
    BOOL _showRefundIntro;
    NSInteger _leaveSeconds;
}

@property (weak, nonatomic) IBOutlet UILabel *needCheckLabel;
@property (weak, nonatomic) IBOutlet UILabel *leaveSecondsLabel;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *activityImageView;
@property (weak, nonatomic) IBOutlet UILabel *activityNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityLocalLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *describeLabel;
@property (weak, nonatomic) IBOutlet UILabel *allMoneyLabel;
@property (weak, nonatomic) IBOutlet UIButton *refundBtn;
@property (weak, nonatomic) IBOutlet UILabel *refundInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *zfbBtn;
@property (weak, nonatomic) IBOutlet UIButton *wxBtn;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation TicketPaymentController
// 作用：拦截手势触发
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return NO;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimerView) userInfo:nil repeats:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wxSuccess) name:@"wxPaymentSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wxFailure:) name:@"wxPaymentFailure" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startTimer) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)startTimer{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimerView) userInfo:nil repeats:YES];
}

- (void)updateTimerView{
    _leaveSeconds = 599 - [NSDate secondsAwayFrom:[NSDate date] dateSecond:self.currentDate];
    if(_leaveSeconds<=0){
        self.leaveSecondsLabel.text = @"订单将在  00：00  后关闭";
        [self.timer invalidate];
        self.timer = nil;
        [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"订单已关闭，请重新下单" cancelButtonTitle:nil otherButtonTitle:@"确定" cancle:nil confirm:^{
            [self customNavBackButtonClicked];
        }];
    }else{
        self.leaveSecondsLabel.text = [NSString stringWithFormat:@"订单将在  %.2ld：%.2ld  后关闭", _leaveSeconds/60, _leaveSeconds%60];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _showRefundIntro = NO;
    [self createCustomNavigationBar:@"确认订单"];
    [self initScrollView:CGRectMake(0, 64, WIDTH, HEIGHT-64-49)];
    self.scrollView.contentSize = CGSizeMake(WIDTH, 589);
    self.scrollView.backgroundColor = kTableViewBgColor;
    self.contentView.frame = CGRectMake(0, 0, WIDTH, 589);
    [self.scrollView addSubview:self.contentView];
    [self updateView];
    if(self.ticketModel.needcheck.integerValue){
        self.needCheckLabel.text = @"*该门票需审核，若审核不通过将为您自动退款。\n";
    }else{
        self.needCheckLabel.text = @"";
    }
    [self updateTimerView];
}

- (void)customNavBackButtonClicked{
    NSArray *viewcontrollers = self.navigationController.viewControllers;
    for(UIViewController *vc in viewcontrollers){
        if([vc isKindOfClass:[ActivityDetailController class]]){
            [self.navigationController popToViewController:vc animated:YES];
            return;
        }else if([vc isKindOfClass:[MyActivityOrderController class]]){
            [self.navigationController popToViewController:vc animated:YES];
            return;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateView{
    [self.activityImageView sd_setImageWithURL:[NSURL URLWithString:self.activityModel.image] placeholderImage:KWidthImageDefault];
    self.activityNameLabel.text = self.activityModel.name;
    self.activityDateLabel.text = self.activityModel.timestr;
    self.activityLocalLabel.text = self.activityModel.address;
    self.typeLabel.text = self.ticketModel.name;
    self.numberLabel.text = [NSString stringWithFormat:@"数量:%ld", (long)self.ticketNum];
    if(self.ticketModel.price.floatValue){
        self.priceLabel.text = [NSString stringWithFormat:@"￥%@元/人", [CommonMethod paramNumberIsNull:self.ticketModel.price]];
    }else{
        self.priceLabel.text = @"免费";
    }
    if([CommonMethod paramStringIsNull:self.ticketModel.remark].length){
        self.describeLabel.text = self.ticketModel.remark;
    }else{
        self.describeLabel.text = @"暂无简介";
    }
    self.allMoneyLabel.text = [NSString stringWithFormat:@"¥%.2f", self.ticketModel.price.floatValue*self.ticketNum];
}

#pragma mark - method
- (IBAction)nextButtonClicked:(id)sender{
    [self.timer invalidate];
    self.timer = nil;
    [self loadHttpData];
}

- (IBAction)showRefundInfoButtonClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    if(sender.selected){
        [self.refundInfoLabel setParagraphText:@"用户可在活动开始时间前24小时之外申请退款，其中由第三方支付平台产生的服务费由用户承担。\n活动开始前24小时之内将无法申请退款。\n" lineSpace:8];
    }else{
        self.refundInfoLabel.text = @"";
    }
}

- (IBAction)zfbButtonClicked:(UIButton *)sender {
    sender.selected = YES;
    self.wxBtn.selected = NO;
}

- (IBAction)wxButtonClicked:(UIButton *)sender {
    sender.selected = YES;
    self.zfbBtn.selected = NO;
}

#pragma mark - 网络请求
- (void)loadHttpData{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    if(self.wxBtn.selected){
        [requestDict setObject:@"wx" forKey:@"paytype"];
    }else{
        [requestDict setObject:@"ali" forKey:@"paytype"];
    }
    [requestDict setObject:self.ordernum forKey:@"ordernum"];
    [self requstType:RequestType_Post apiName:API_NAME_POST_ACTIVITY_CHECKORDERPAY paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSDictionary *dict = [CommonMethod paramDictIsNull:responseObject[@"data"]];
            if(weakSelf.wxBtn.selected){
                [weakSelf wxPayment:dict];
            }else{
                [weakSelf aliPayment:dict];
            }
        }else{
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimerView) userInfo:nil repeats:YES];
            [MBProgressHUD showError:[CommonMethod paramStringIsNull:responseObject[@"msg"]] toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimerView) userInfo:nil repeats:YES];
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络设置" toView:weakSelf.view];
    }];
}

#pragma mark -微信支付
- (void)wxPayment:(NSDictionary*)dict{
    PayReq *request = [[PayReq alloc] init];
    request.partnerId = [CommonMethod paramStringIsNull:dict[@"partnerid"]];
    request.prepayId = [CommonMethod paramStringIsNull:dict[@"prepayid"]];
    request.package = [CommonMethod paramStringIsNull:dict[@"package"]];
    request.nonceStr = [CommonMethod paramStringIsNull:dict[@"noncestr"]];
    request.timeStamp = [CommonMethod paramNumberIsNull:dict[@"timestamp"]].intValue;
    request.sign = [CommonMethod paramStringIsNull:dict[@"sign"]];
    [WXApi sendReq:request];
}

- (void)wxSuccess{
    NSInteger seconds = 599 - [NSDate secondsAwayFrom:[NSDate date] dateSecond:self.currentDate];
    if(seconds < 0){
        self.currentDate = [NSDate getDate:self.currentDate seconds:60];
    }

    ApplySucceedController *vc = [CommonMethod getVCFromNib:[ApplySucceedController class]];
    vc.actModel = self.activityModel;
    vc.needcheck = self.ticketModel.needcheck;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)wxFailure:(NSNotification*)notification{
//    WXErrCodeCommon     = -1,   /**< 普通错误类型    */
//    WXErrCodeUserCancel = -2,   /**< 用户点击取消并返回    */
//    WXErrCodeSentFail   = -3,   /**< 发送失败    */
//    WXErrCodeAuthDeny   = -4,   /**< 授权失败    */
//    WXErrCodeUnsupport  = -5,   /**< 微信不支持    */
    NSString *errorStr = @"";
    NSNumber *error = [notification object];
    switch (error.integerValue) {
        case -1:
            errorStr = @"支付失败";
            break;
        case -2:
            errorStr = @"支付取消";
            break;
        case -3:
            errorStr = @"发送失败";
            break;
        case -4:
            errorStr = @"授权失败";
            break;
        case -5:
            errorStr = @"微信不支持";
            break;
        default:
            errorStr = @"支付取消";
            break;
    }
    if (errorStr.length) {
        [[[CommonUIAlert alloc] init] showCommonAlertView:self title:errorStr message:@"" cancelButtonTitle:nil otherButtonTitle:@"确定" cancle:nil confirm:^{
            [self customNavBackButtonClicked];
        }];
    }
}

#pragma mark -支付宝支付
- (void)aliPayment:(NSDictionary*)dict{
    [[AlipaySDK defaultService] payOrder:[CommonMethod paramStringIsNull:dict[@"alisign"]] fromScheme:@"com.fortunecoffee.51JinMai" callback:^(NSDictionary *resultDic) {
        NSLog(@"reslut = %@",resultDic);
        if([CommonMethod paramStringIsNull:resultDic[@"resultStatus"]].integerValue == 9000){
            NSInteger seconds = 599 - [NSDate secondsAwayFrom:[NSDate date] dateSecond:self.currentDate];
            if(seconds < 0){
                self.currentDate = [NSDate getDate:self.currentDate seconds:60];
            }
            
            ApplySucceedController *vc = [CommonMethod getVCFromNib:[ApplySucceedController class]];
            vc.actModel = self.activityModel;
            vc.needcheck = self.ticketModel.needcheck;
            [self.navigationController pushViewController:vc animated:YES];
        }else if([CommonMethod paramStringIsNull:resultDic[@"resultStatus"]].integerValue != 6001){
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:[CommonMethod paramStringIsNull:resultDic[@"memo"]] message:@"" cancelButtonTitle:nil otherButtonTitle:@"确定" cancle:nil confirm:^{
                [self customNavBackButtonClicked];
            }];
        }
    }];
}

@end
