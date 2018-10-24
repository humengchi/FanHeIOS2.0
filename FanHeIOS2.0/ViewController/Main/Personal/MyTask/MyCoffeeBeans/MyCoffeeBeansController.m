//
//  MyCoffeeBeansController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "MyCoffeeBeansController.h"
#import "BuyCoffeeBeansController.h"
#import "MyCoffeeBeansCell.h"
#import "TaskListViewController.h"
#import "ScanCameraController.h"
#import "SearchCompanyViewController.h"
#import "ChoiceNeedSupplyController.h"
#import "NeedSupplyErrorView.h"

@interface MyCoffeeBeansController ()

@end

@implementation MyCoffeeBeansController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self getCoffeeBeans];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar];
    
    [self initGroupedTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    self.tableView.separatorColor = kCellLineColor;
    [self initTableHeaderView];
}

- (void)createCustomNavigationBar{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 64)];
    barView.backgroundColor = HEX_COLOR(@"e24943");
    [self.view addSubview:barView];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 20, 44, 44);
    [backBtn setImage:kImageWithName(@"btn_reture_white") forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(customNavBackButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [barView addSubview:backBtn];
}

- (void)customNavBackButtonClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 我的咖啡豆数量
- (void)getCoffeeBeans{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@",[DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_USER_MYCOFFEEBEANS paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        NSNumber *coffeeBeans = @(0);
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            coffeeBeans = [CommonMethod paramNumberIsNull:responseObject[@"data"][@"cb"]];
            if(coffeeBeans.integerValue != [DataModelInstance shareInstance].coffeeBeans.integerValue){
                [DataModelInstance shareInstance].coffeeBeans = coffeeBeans;
                [weakSelf initTableHeaderView];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

#pragma mark -初始化列表头
- (void)initTableHeaderView{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 201)];
    headerView.backgroundColor = HEX_COLOR(@"e24943");
    
    UILabel *titleLabel1 = [UILabel createrLabelframe:CGRectMake(0, 5, WIDTH, 15) backColor:HEX_COLOR(@"e24943") textColor:WHITE_COLOR test:@"当前咖啡豆" font:14 number:1 nstextLocat:NSTextAlignmentCenter];
    [headerView addSubview:titleLabel1];
    
    UILabel *titleLabel2 = [UILabel createrLabelframe:CGRectMake(0, 31, WIDTH, 33) backColor:HEX_COLOR(@"e24943") textColor:WHITE_COLOR test:@"" font:32 number:1 nstextLocat:NSTextAlignmentCenter];
    [headerView addSubview:titleLabel2];
    NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:[CommonMethod paramNumberIsNull:[DataModelInstance shareInstance].coffeeBeans].stringValue];
    NSTextAttachment *attchImage = [[NSTextAttachment alloc] init];
    attchImage.image = kImageWithName(@"icon_kfd_white");
    attchImage.bounds = CGRectMake(4, 2, 13, 15);
    NSAttributedString *stringImage = [NSAttributedString attributedStringWithAttachment:attchImage];
    [attriStr appendAttributedString:stringImage];
    titleLabel2.attributedText = attriStr;
    
    
    UIButton *taskBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    taskBtn.frame = CGRectMake(25, 79, (WIDTH-65)/2, 53);
    [taskBtn setBackgroundColor:HEX_COLOR(@"e24943")];
    [taskBtn addTarget:self action:@selector(gotoTaskListVC) forControlEvents:UIControlEventTouchUpInside];
    [CALayer updateControlLayer:taskBtn.layer radius:5 borderWidth:0.5 borderColor:WHITE_COLOR.CGColor];
    [headerView addSubview:taskBtn];
    UILabel *taskBtnLabel1 = [UILabel createrLabelframe:CGRectMake(25.5, 87, (WIDTH-65)/2-1, 18) backColor:HEX_COLOR(@"e24943") textColor:WHITE_COLOR test:@"做任务" font:17 number:1 nstextLocat:NSTextAlignmentCenter];
    [headerView addSubview:taskBtnLabel1];
    UILabel *taskBtnLabel2 = [UILabel createrLabelframe:CGRectMake(25.5, 110, (WIDTH-65)/2-1, 15) backColor:HEX_COLOR(@"e24943") textColor:WHITE_COLOR test:@"赢取咖啡豆" font:14 number:1 nstextLocat:NSTextAlignmentCenter];
    [headerView addSubview:taskBtnLabel2];
    
    UIButton *rechargeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rechargeBtn.frame = CGRectMake(40+(WIDTH-65)/2, 79, (WIDTH-65)/2, 53);
    [rechargeBtn setBackgroundColor:WHITE_COLOR];
    [rechargeBtn addTarget:self action:@selector(gotoBuyCoffeeBeansVC) forControlEvents:UIControlEventTouchUpInside];
    [CALayer updateControlLayer:rechargeBtn.layer radius:5 borderWidth:0.5 borderColor:WHITE_COLOR.CGColor];
    [headerView addSubview:rechargeBtn];
    UILabel *rechargeBtnLabel1 = [UILabel createrLabelframe:CGRectMake(40+(WIDTH-65)/2, 87, (WIDTH-65)/2, 18) backColor:WHITE_COLOR textColor:HEX_COLOR(@"e24943") test:@"去充值" font:17 number:1 nstextLocat:NSTextAlignmentCenter];
    [headerView addSubview:rechargeBtnLabel1];
    UILabel *rechargeBtnLabel2 = [UILabel createrLabelframe:CGRectMake(40+(WIDTH-65)/2, 110, (WIDTH-65)/2, 15) backColor:WHITE_COLOR textColor:HEX_COLOR(@"e24943") test:@"获得咖啡豆" font:14 number:1 nstextLocat:NSTextAlignmentCenter];
    [headerView addSubview:rechargeBtnLabel2];
    
    UILabel *countLabel = [UILabel createrLabelframe:CGRectMake(0, 157, WIDTH, 44) backColor:kTableViewBgColor textColor:HEX_COLOR(@"818c9e") test:@"使用咖啡豆可以享受以下特权" font:17 number:1 nstextLocat:NSTextAlignmentCenter];
    [headerView addSubview:countLabel];
    
    self.tableView.tableHeaderView = headerView;
}

#pragma mark -method
- (void)gotoBuyCoffeeBeansVC{
    BuyCoffeeBeansController *vc = [CommonMethod getVCFromNib:[BuyCoffeeBeansController class]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoTaskListVC{
    TaskListViewController *vc = [[TaskListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate/datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 85;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 46;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 46)];
    headerView.backgroundColor = WHITE_COLOR;
    UILabel *label = [UILabel createLabel:CGRectMake(16, 0, WIDTH-32, 46) font:FONT_SYSTEM_SIZE(14) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e")];
    label.text = @"特权";
    [headerView addSubview:label];
    return headerView;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 0)];
    footerView.backgroundColor = kTableViewBgColor;
    return footerView;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"MyCoffeeBeansCell";
    MyCoffeeBeansCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [CommonMethod getViewFromNib:@"MyCoffeeBeansCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell updateDisplay:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row==0){
        SearchCompanyViewController *vc = [[SearchCompanyViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if(indexPath.row==1){
        __weak typeof(self) weakSelf = self;
        __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"请求中..." toView:self.view];
        NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
        [requestDict setObject:[NSString stringWithFormat:@"/%@",[DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
        [self requstType:RequestType_Get apiName:API_NAME_GET_USER_RESTGX paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
            [hud hideAnimated:YES];
            if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
                NSDictionary *dic = [CommonMethod paramDictIsNull:responseObject[@"data"]];
                NSNumber *rest_times = [CommonMethod paramNumberIsNull:dic[@"rest_times"]];
                if (rest_times.integerValue > 0) {
                    ChoiceNeedSupplyController *vc = [[ChoiceNeedSupplyController alloc]init];
                    vc.limit_times_cn = [CommonMethod paramStringIsNull:dic[@"limit_times_cn"]];
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                }else{
                    NeedSupplyErrorView *view = [CommonMethod getViewFromNib:@"NeedSupplyErrorView"];
                    view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
                    view.limit_times_cn = [CommonMethod paramStringIsNull:dic[@"limit_times_cn"]];
                    view.confirmButtonClicked = ^{
                        ChoiceNeedSupplyController *vc = [[ChoiceNeedSupplyController alloc]init];
                        vc.limit_times_cn = [CommonMethod paramStringIsNull:dic[@"limit_times_cn"]];
                        [weakSelf.navigationController pushViewController:vc animated:YES];
                    };
                    [[UIApplication sharedApplication].keyWindow addSubview:view];
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
            [hud hideAnimated:YES];
        }];
    }else{
        ScanCameraController *vc = [CommonMethod getVCFromNib:[ScanCameraController class]];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if(scrollView.contentOffset.y<0){
        [scrollView setContentOffset:CGPointMake(0, 0)];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView.contentOffset.y<0){
        [scrollView setContentOffset:CGPointMake(0, 0)];
    }
}

@end
