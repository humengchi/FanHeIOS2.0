//
//  TicketDetailViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/6/8.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "TicketDetailViewController.h"
#import "TicketDetailCell.h"
#import "TicketApplyRefundController.h"
#import "TicketPaymentController.h"
#import "ActivityDetailController.h"

@interface TicketDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *ordernumLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *actImageView;
@property (weak, nonatomic) IBOutlet UILabel *actNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *actTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *actAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *ticketNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountRealLabel;
@property (weak, nonatomic) IBOutlet UIButton *footBtn;
@property (weak, nonatomic) IBOutlet UIButton *payBtn;

@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UIView *footerView;

@property (nonatomic, strong) ActivityOrderModel *orderModel;
@property (nonatomic, strong) NSMutableArray *ticketsArray;

@end

@implementation TicketDetailViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    [self loadHttpData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.ticketsArray = [NSMutableArray array];
    
    self.view.backgroundColor = HEX_COLOR(@"f7f7f7");
    [self createCustomNavigationBar:@"订单详情"];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.headerView.frame = CGRectMake(0, 0, WIDTH, 221);
    self.tableView.tableHeaderView = self.headerView;
    self.payBtn.hidden = YES;
    self.tableView.hidden = YES;
    
    [self updateButton:self.status amount:self.amount];
}

- (void)updateView{
    self.payBtn.hidden = NO;
    self.stateLabel.text = self.orderModel.stat;
    [self updateButton:self.orderModel.status amount:self.orderModel.amount];
    self.ordernumLabel.text = [NSString stringWithFormat:@"订单编号：%@", self.orderModel.ordernum];
    self.timeLabel.text = [NSString stringWithFormat:@"创建时间：%@", self.orderModel.created_at];
    
    [self.actImageView sd_setImageWithURL:[NSURL URLWithString:self.orderModel.image] placeholderImage:KWidthImageDefault];
    self.actNameLabel.text = self.orderModel.name;
    self.actTimeLabel.text = self.orderModel.timestr;
    self.actAddressLabel.text = self.orderModel.address;
    
    self.ticketNumLabel.text = [NSString stringWithFormat:@"%@张", self.orderModel.ticketnum];
    self.amountLabel.text = [NSString stringWithFormat:@"¥ %@元", self.orderModel.amount];
    self.amountRealLabel.text = [NSString stringWithFormat:@"¥ %@元", self.orderModel.payamount];
    
    [self.tableView reloadData];
}

- (void)updateButton:(NSNumber*)orderStatus amount:(NSString*)orderAmount{
    if(self.status.integerValue == 0){
        self.footerView.frame = CGRectMake(0, 0, WIDTH, 121);
        self.tableView.tableFooterView = self.footerView;
    }else{
        self.footerView.frame = CGRectMake(0, 0, WIDTH, 207);
        self.tableView.tableFooterView = self.footerView;
    }
    if(orderStatus.integerValue == 0){
        self.tableView.frame = CGRectMake(0, 64, WIDTH, HEIGHT-64-49);
    }else{
        self.tableView.frame = CGRectMake(0, 64, WIDTH, HEIGHT-64);
    }
    if(orderStatus.integerValue == 0){//待支付
        self.stateLabel.textColor = HEX_COLOR(@"e24943");
    }else if(orderStatus.integerValue == 1){//已付款
        self.stateLabel.textColor = HEX_COLOR(@"1abc9c");
        if(orderAmount.floatValue){
            [self.footBtn setTitle:@"申请退票" forState:UIControlStateNormal];
        }else{
            [self.footBtn setTitle:@"取消报名" forState:UIControlStateNormal];
        }
        [self.footBtn setTitleColor:HEX_COLOR(@"e24943") forState:UIControlStateNormal];
        [self.footBtn setBackgroundImage:kImageWithName(@"btn_bg_sqtk") forState:UIControlStateNormal];
        self.footBtn.userInteractionEnabled = YES;
    }else if(orderStatus.integerValue == 2){//审核中
        self.stateLabel.textColor = HEX_COLOR(@"f76b1c");
        if(orderAmount.floatValue){
            [self.footBtn setTitle:@"申请退票" forState:UIControlStateNormal];
        }else{
            [self.footBtn setTitle:@"取消报名" forState:UIControlStateNormal];
        }
        [self.footBtn setTitleColor:HEX_COLOR(@"e24943") forState:UIControlStateNormal];
        [self.footBtn setBackgroundImage:kImageWithName(@"btn_bg_sqtk") forState:UIControlStateNormal];
        self.footBtn.userInteractionEnabled = YES;
    }else if(orderStatus.integerValue == 3){//退款中
        self.stateLabel.textColor = HEX_COLOR(@"f76b1c");
        [self.footBtn setTitle:@"退款处理中" forState:UIControlStateNormal];
        [self.footBtn setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
        [self.footBtn setBackgroundImage:kImageWithName(@"btn_bg_se") forState:UIControlStateNormal];
        self.footBtn.userInteractionEnabled = NO;
    }else if(orderStatus.integerValue == 4){//已退款
        self.stateLabel.textColor = HEX_COLOR(@"e24943");
        [self.footBtn setTitle:@"退款处理中" forState:UIControlStateNormal];
        [self.footBtn setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
        [self.footBtn setBackgroundImage:kImageWithName(@"btn_bg_se") forState:UIControlStateNormal];
        self.footBtn.userInteractionEnabled = NO;
    }else if(orderStatus.integerValue == 5){//已取消
        self.stateLabel.textColor = HEX_COLOR(@"afb6c1");
        [self.footBtn setTitle:@"已取消" forState:UIControlStateNormal];
        [self.footBtn setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
        [self.footBtn setBackgroundImage:kImageWithName(@"btn_bg_se") forState:UIControlStateNormal];
        self.footBtn.userInteractionEnabled = NO;
    }else{//已结束
        self.stateLabel.textColor = HEX_COLOR(@"afb6c1");
        if(orderAmount.floatValue){
            [self.footBtn setTitle:@"申请退票" forState:UIControlStateNormal];
        }else{
            [self.footBtn setTitle:@"取消报名" forState:UIControlStateNormal];
        }
        [self.footBtn setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
        [self.footBtn setBackgroundImage:kImageWithName(@"btn_bg_se") forState:UIControlStateNormal];
        self.footBtn.userInteractionEnabled = NO;
    }
}

#pragma mark - method
- (IBAction)payButtonCliked:(id)sender{
    if([NSDate secondsAwayFrom:[NSDate date] dateSecond:[NSDate dateFromString:self.orderModel.created_at format:kTimeFormat]] > 10*60){
        [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"订单已关闭，请重新下单" cancelButtonTitle:nil otherButtonTitle:@"确定" cancle:nil confirm:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        return;
    }
    TicketPaymentController *vc = [CommonMethod getVCFromNib:[TicketPaymentController class]];
    MyActivityModel *actModel = [[MyActivityModel alloc] init];
    actModel.name = self.orderModel.name;
    actModel.image = self.orderModel.image;
    actModel.address = self.orderModel.address;
    actModel.timestr = self.orderModel.timestr;
    actModel.activityid = self.orderModel.activityid;
    actModel.subcontent = self.orderModel.subcontent;
    vc.activityModel = actModel;
    TicketPersonInfoModel *model = self.ticketsArray[0];
    TicketModel *ticketModel = [[TicketModel alloc] init];
    ticketModel.name = model.ticketname;
    ticketModel.price = @(model.price.floatValue);
    ticketModel.remark = model.remark;
    ticketModel.needcheck = self.orderModel.needcheck;
    vc.ticketModel = ticketModel;
    vc.ticketNum = self.orderModel.ticketnum.integerValue;
    vc.ordernum = self.ordernum;
    vc.currentDate = [NSDate dateFromString:self.orderModel.created_at format:kTimeFormat];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)refundButtonClicked:(id)sender{
    if([NSDate secondsAwayFrom:[NSDate date] dateSecond:[NSDate dateFromString:self.orderModel.starttime format:kTimeFormat]] > 0 || [NSDate secondsAwayFrom:[NSDate dateFromString:self.orderModel.starttime format:kTimeFormat] dateSecond:[NSDate date]] < 24*60*60){
        [self.view showToastMessage:@"活动即将开始，已无法退票"];
        return;
    }
    TicketApplyRefundController *vc = [CommonMethod getVCFromNib:[TicketApplyRefundController class]];
    vc.ordernum = self.ordernum;
    vc.amount = self.orderModel.amount;
    vc.startDate = [NSDate dateFromString:self.orderModel.starttime format:kTimeFormat];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)gotoActivityDetailButtonClicked:(id)sender{
    ActivityDetailController *vc = [CommonMethod getVCFromNib:[ActivityDetailController class]];
    vc.activityid = self.orderModel.activityid;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 网络请求
- (void)loadHttpData{
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@", self.ordernum, [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_ACTIVITY_ORDER_DETAIL paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        self.tableView.hidden = NO;
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSDictionary *dict = [CommonMethod paramDictIsNull:responseObject[@"data"]];
            self.orderModel = [[ActivityOrderModel alloc] initWithDict:dict];
            [self.ticketsArray removeAllObjects];
            for(NSDictionary *ticketDict in [CommonMethod paramArrayIsNull:dict[@"tickets"]]){
                TicketPersonInfoModel *model = [[TicketPersonInfoModel alloc] initWithDict:ticketDict];
                [self.ticketsArray addObject:model];
            }
            self.status = self.orderModel.status;
        }
        [self updateView];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络设置" toView:self.view];
    }];
}

#pragma mark - UITableViewDelegate/DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.ticketsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 97.0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"TicketDetailCell";
    TicketDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [CommonMethod getViewFromNib:@"TicketDetailCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    TicketPersonInfoModel *model = self.ticketsArray[indexPath.row];
    [cell updateDisplay:model];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
