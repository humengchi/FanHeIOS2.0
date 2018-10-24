//
//  MyActivityOrderController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/6/13.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "MyActivityOrderController.h"
#import "MyActivityOrderCell.h"
#import "TicketDetailViewController.h"
#import "TicketApplyRefundController.h"
#import "TicketPaymentController.h"
#import "NODataTableViewCell.h"
#import "ActivityViewController.h"

@interface MyActivityOrderController ()<MyActivityOrderCellDelegate>{
    NSInteger _currentType;
    BOOL _needRefresh;
}

@property (nonatomic, weak) IBOutlet UIView *btnsView;
@property (nonatomic, weak) IBOutlet UILabel *redLineLabel;

@property (nonatomic, strong) NSMutableArray *allArray;
@property (nonatomic, strong) NSMutableArray *payArray;
@property (nonatomic, strong) NSMutableArray *refundArray;

@property (nonatomic, assign) BOOL allNoData;
@property (nonatomic, assign) BOOL payNoData;
@property (nonatomic, assign) BOOL refundNoData;

@end

@implementation MyActivityOrderController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    _needRefresh = YES;
    [self loadHttpData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentType = 0;
    [self createCustomNavigationBar:@"我的订单"];
    
    [self initTableView:CGRectMake(0, 107, WIDTH, HEIGHT-107)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.redLineLabel.frame = CGRectMake((WIDTH/3-65)/2, 41, 65, 2);
    
    [self.tableView tableViewAddDownLoadRefreshing:^{
        _needRefresh = YES;
        [self loadHttpData];
    }];
    
    [self.tableView tableViewAddUpLoadRefreshing:^{
        [self loadHttpData];
    }];
}

#pragma mark -method 
- (IBAction)chooseButtonClicked:(UIButton*)sender{
    [UIView animateWithDuration:0.3 animations:^{
        self.redLineLabel.frame = CGRectMake((WIDTH/3-65)/2+sender.tag*WIDTH/3, 41, 65, 2);
    }];
    _currentType = sender.tag;
    BOOL noData = NO;
    BOOL needLoadData = NO;
    if(sender.tag == 0){
        noData = self.allNoData;
        needLoadData = self.allArray.count==0;
    }else if(sender.tag == 1){
        noData = self.payNoData;
        needLoadData = self.payArray.count==0;
    }else{
        noData = self.refundNoData;
        needLoadData = self.refundArray.count==0;
    }
    if(noData){
        [self.tableView endRefreshNoData];
    }else{
        [self.tableView.mj_footer resetNoMoreData];
    }
    if(needLoadData){
        [self.tableView reloadData];
        [self loadHttpData];
    }else{
        [self.tableView reloadData];
    }
}

#pragma mark - 网络请求
- (void)loadHttpData{
    NSString *stat;
    NSInteger page;
    NSInteger arrayCount = 0;
    if(_currentType == 0){
        stat = @"all";
        if(self.allArray){
            page = self.allArray.count/20+1+(self.allArray.count%20?1:0);
            arrayCount = self.allArray.count;
        }else{
            page = 1;
            arrayCount = 0;
        }
    }else if(_currentType == 1){
        stat = @"pay";
        if(self.payArray){
            page = self.payArray.count/20+1+(self.payArray.count%20?1:0);
            arrayCount = self.payArray.count;
        }else{
            page = 1;
            arrayCount = 0;
        }
    }else{
        stat = @"refund";
        if(self.refundArray){
            page = self.refundArray.count/20+1+(self.refundArray.count%20?1:0);
            arrayCount = self.refundArray.count;
        }else{
            page = 1;
            arrayCount = 0;
        }
    }
    if(_needRefresh){
        page = 1;
    }
    
    __weak MBProgressHUD *hud;
    if(arrayCount == 0){
        hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    }
    self.btnsView.userInteractionEnabled = NO;
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@/%ld", [DataModelInstance shareInstance].userModel.userId, stat, (long)page]  forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_ACTIVITY_MY_ORDERS paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [weakSelf.tableView endRefresh];
        weakSelf.btnsView.userInteractionEnabled = YES;
        if(_currentType == 0 && !weakSelf.allArray){
            weakSelf.allArray = [NSMutableArray array];
        }else if(_currentType == 1 && !weakSelf.payArray){
            weakSelf.payArray = [NSMutableArray array];
        }else if(_currentType == 2 && !weakSelf.refundArray){
            weakSelf.refundArray = [NSMutableArray array];
        }
        if(_needRefresh){
            if(_currentType == 0){
                [weakSelf.allArray removeAllObjects];
                weakSelf.allNoData = NO;
            }else if(_currentType == 1){
                [weakSelf.payArray removeAllObjects];
                weakSelf.payNoData = NO;
            }else{
                [weakSelf.refundArray removeAllObjects];
                weakSelf.refundNoData = NO;
            }
//            [weakSelf.tableView reloadData];
        }
        _needRefresh = NO;
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSMutableArray *array = [NSMutableArray array];
            for(NSDictionary *dict in [CommonMethod paramArrayIsNull:responseObject[@"data"]]){
                ActivityOrderModel *model = [[ActivityOrderModel alloc] initWithDict:dict];
                [array addObject:model];
            }
            if(array.count < 20){
                [weakSelf.tableView endRefreshNoData];
            }
            if(array.count){
                if(_currentType == 0){
                    [weakSelf.allArray addObjectsFromArray:array];
                }else if(_currentType == 1){
                    [weakSelf.payArray addObjectsFromArray:array];
                }else{
                    [weakSelf.refundArray addObjectsFromArray:array];
                }
            }
        }
        [weakSelf.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        if(_currentType == 0 && !weakSelf.allArray){
            weakSelf.allArray = [NSMutableArray array];
        }else if(_currentType == 1 && !weakSelf.payArray){
            weakSelf.payArray = [NSMutableArray array];
        }else if(_currentType == 2 && !weakSelf.refundArray){
            weakSelf.refundArray = [NSMutableArray array];
        }
        [hud hideAnimated:YES];
        [weakSelf.tableView endRefresh];
        weakSelf.btnsView.userInteractionEnabled = YES;
        _needRefresh = NO;
    }];
}

#pragma mark - UITableViewDelegate/DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 0;
    if(_currentType == 0 && self.allArray){
        row = self.allArray.count;
    }else if(_currentType == 1 && self.payArray){
        row = self.payArray.count;
    }else if(_currentType == 2 && self.refundArray){
        row = self.refundArray.count;
    }else{
        return 0;
    }
    if (row==0) {
        row = 1;
    }
    return row;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = 0;
    if(_currentType == 0){
        row = self.allArray.count;
    }else if(_currentType == 1){
        row = self.payArray.count;
    }else{
        row = self.refundArray.count;
    }
    if (row==0) {
        return self.tableView.frame.size.height;
    }
    ActivityOrderModel *model;
    if(_currentType == 0){
        model = self.allArray[indexPath.row];
    }else if(_currentType == 1){
        model = self.payArray[indexPath.row];
    }else{
        model = self.refundArray[indexPath.row];
    }
    if(model.status.integerValue == 5){
        return 193.0;
    }else{
        return 246.0;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = 0;
    if(_currentType == 0){
        row = self.allArray.count;
    }else if(_currentType == 1){
        row = self.payArray.count;
    }else{
        row = self.refundArray.count;
    }
    if (row==0) {
        static NSString *identify = @"NODataTableViewCell";
        NODataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"NODataTableViewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.coverImageView.image = kImageWithName(@"icon_event_b");
        cell.mainLabel.text = @"你还没有订单";
        cell.subLabel.text = @"去看看有什么最新的活动吧！";
        cell.btnImageView.hidden = NO;
        cell.clickButton = ^(){
            ActivityViewController *activity = [CommonMethod getVCFromNib:[ActivityViewController class]];
            activity.showBackBtn = YES;
            [self.navigationController pushViewController:activity animated:YES];
        };
        return cell;
    }else{
        static NSString *identify = @"MyActivityOrderCell";
        MyActivityOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"MyActivityOrderCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.delegate = self;
        cell.tag = indexPath.row;
        ActivityOrderModel *model;
        if(_currentType == 0){
            model = self.allArray[indexPath.row];
        }else if(_currentType == 1){
            model = self.payArray[indexPath.row];
        }else{
            model = self.refundArray[indexPath.row];
        }
        [cell updateDisplay:model];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger row = 0;
    if(_currentType == 0){
        row = self.allArray.count;
    }else if(_currentType == 1){
        row = self.payArray.count;
    }else{
        row = self.refundArray.count;
    }
    if (row) {
        ActivityOrderModel *model;
        if(_currentType == 0){
            model = self.allArray[indexPath.row];
        }else if(_currentType == 1){
            model = self.payArray[indexPath.row];
        }else{
            model = self.refundArray[indexPath.row];
        }
        TicketDetailViewController *vc = [CommonMethod getVCFromNib:[TicketDetailViewController class]];
        vc.ordernum = model.ordernum;
        vc.status = model.status;
        vc.amount = model.amount;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [self loadHttpData];
    }
}

#pragma mark -
- (void)myActivityOrderClickedFirstBtn:(MyActivityOrderCell *)cell model:(ActivityOrderModel *)model{
    if(model.status.integerValue == 0){//待支付
        [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"取消订单" message:@"取消后订单不可恢复，是否继续？" cancelButtonTitle:@"确定" otherButtonTitle:@"返回" cancle:^{
            __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
            __weak typeof(self) weakSelf = self;
            NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
            [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
            [requestDict setObject:model.ordernum forKey:@"ordernum"];
            [requestDict setObject:@"取消订单" forKey:@"remark"];
            [self requstType:RequestType_Post apiName:API_NAME_POST_ACTIVITY_CANCLE_APPLY paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
                [hud hideAnimated:YES];
                if([CommonMethod isHttpResponseSuccess:responseObject]){
                    _needRefresh = YES;
                    [weakSelf loadHttpData];
                }else{
                    [MBProgressHUD showError:[CommonMethod paramStringIsNull:responseObject[@"msg"]] toView:weakSelf.view];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
                [hud hideAnimated:YES];
                [MBProgressHUD showError:@"网络请求失败，请检查网络设置" toView:weakSelf.view];
            }];
        } confirm:^{
            
        }];
        return;
    }
    if([NSDate secondsAwayFrom:[NSDate date] dateSecond:[NSDate dateFromString:model.starttime format:kTimeFormat]] > 0 || [NSDate secondsAwayFrom:[NSDate dateFromString:model.starttime format:kTimeFormat] dateSecond:[NSDate date]] < 24*60*60){
        [self.view showToastMessage:@"活动即将开始，已无法退票"];
        return;
    }
    if(model.status.integerValue == 1){//已付款
        TicketApplyRefundController *vc = [CommonMethod getVCFromNib:[TicketApplyRefundController class]];
        vc.ordernum = model.ordernum;
        vc.amount = model.amount;
        vc.startDate = [NSDate dateFromString:model.starttime format:kTimeFormat];
        [self.navigationController pushViewController:vc animated:YES];
    }else if(model.status.integerValue == 2){//审核中
        TicketApplyRefundController *vc = [CommonMethod getVCFromNib:[TicketApplyRefundController class]];
        vc.ordernum = model.ordernum;
        vc.amount = model.amount;
        vc.startDate = [NSDate dateFromString:model.starttime format:kTimeFormat];
        [self.navigationController pushViewController:vc animated:YES];
    }else if(model.status.integerValue == 3){//退款中
    }else if(model.status.integerValue == 4){//已退款
    }else{//已取消
    }
}

- (void)myActivityOrderClickedSecondBtn:(MyActivityOrderCell *)cell model:(ActivityOrderModel *)model{
    if(model.status.integerValue == 0){//待支付
        TicketPaymentController *vc = [CommonMethod getVCFromNib:[TicketPaymentController class]];
        MyActivityModel *actModel = [[MyActivityModel alloc] init];
        actModel.name = model.name;
        actModel.image = model.image;
        actModel.address = model.cityname;
        actModel.timestr = model.timestr;
        actModel.activityid = model.activityid;
        actModel.subcontent = model.subcontent;
        vc.activityModel = actModel;
        TicketModel *ticketModel = [[TicketModel alloc] init];
        ticketModel.name = model.ticketname;
        ticketModel.price = @(model.price.floatValue);
        ticketModel.remark = model.remark;
        ticketModel.needcheck = model.needcheck;
        vc.ticketModel = ticketModel;
        vc.ticketNum = model.ticketnum.integerValue;
        vc.ordernum = model.ordernum;
        vc.currentDate = [NSDate dateFromString:model.created_at format:kTimeFormat];
        [self.navigationController pushViewController:vc animated:YES];
    }else{//已取消
        TicketDetailViewController *vc = [CommonMethod getVCFromNib:[TicketDetailViewController class]];
        vc.ordernum = model.ordernum;
        vc.status = model.status;
        vc.amount = model.amount;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
@end
