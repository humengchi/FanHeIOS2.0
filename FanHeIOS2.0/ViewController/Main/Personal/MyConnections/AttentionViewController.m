
//
//  AttentionViewController.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/29.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "AttentionViewController.h"
#import "AttentionCell.h"
#import "NONetWorkTableViewCell.h"
#import "AttentionCell.h"
#import "CofferNopeopleCell.h"

@interface AttentionViewController ()<AttentionCellDelegate>
@property (nonatomic,assign) BOOL  netWorkStat;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,assign) NSInteger currentPag;
@end

@implementation AttentionViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.typeIndex == 1) {
        [self createCustomNavigationBar:@"我关注的"];
    }else{
        [self createCustomNavigationBar:@"关注我的"];
    }
    
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.currentPag = 1;
    [self.tableView tableViewAddUpLoadRefreshing:^{
        self.currentPag ++;
        [self getAttionTaCofferInformation:self.currentPag];
    }];
    [self.tableView tableViewAddDownLoadRefreshing:^{
        self.currentPag = 1;
        [self getAttionTaCofferInformation:self.currentPag];
    }];
    [self getAttionTaCofferInformation:self.currentPag];
    if (self.typeIndex == 2) {
        [self delectMessageCount];
    }
    
}

#pragma mark - 消息已读
- (void)delectMessageCount{
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:@(10) forKey:@"type"];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [self requstType:RequestType_Post apiName:API_NAME_USER_POST_CLEARMESSAGE paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

#pragma mark --- 网络请求数据
- (void)getAttionTaCofferInformation:(NSInteger)page{
    self.netWorkStat = NO;
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    if (self.currentPag == 1) {
        [self.dataArray removeAllObjects];
    }
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%ld", [DataModelInstance shareInstance].userModel.userId,(long)self.currentPag] forKey:@"param"];
    NSString *strApi;
    if (self.typeIndex == 1) {
        strApi = API_NAME_USER_GET_ATTIONMYIFONMATION;
    }else{
        strApi = API_NAME_USER_GET_MYATTIONOTHERPEOPLE;
    }
    [self requstType:RequestType_Get apiName:strApi paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if(self.dataArray == nil){
            self.dataArray = [NSMutableArray array];
        }
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *subArray = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            for (NSDictionary *subDic in subArray) {
                ChartModel *coffModel = [[ChartModel alloc] initWithDict:subDic];
                [self.dataArray addObject:coffModel];
            }
            if(subArray.count){
                [self.tableView.mj_footer endRefreshing];
            }else{
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            [self.tableView.mj_header endRefreshing];
            [self.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        if(self.dataArray == nil){
            self.dataArray = [NSMutableArray array];
        }
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        self.netWorkStat = YES;
        [self.tableView reloadData];
    }];
    
}

#pragma mark - UITableVieDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.dataArray==nil){
        return 0;
    }else if(self.dataArray.count){
        return self.dataArray.count;
    }else{
        return 1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES || self.dataArray.count == 0){
        return self.tableView.frame.size.height;
    }
    return 53;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat){
        static NSString *cellID = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([NONetWorkTableViewCell class])];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        self.tableView.tableHeaderView = [UIView new];
        return cell;
    }else if(self.dataArray.count == 0){
        static NSString *string = @"FriendsCell";
        CofferNopeopleCell *cell = [tableView dequeueReusableCellWithIdentifier:string];
        if (!cell){
            cell = [CommonMethod getViewFromNib:NSStringFromClass([CofferNopeopleCell class])];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if (self.typeIndex == 1) {
            cell.showLabel.text = @"暂无我关注的人";
            cell.showImageView.image = [UIImage imageNamed:@"icon_warn_attention"];
        }else{
            cell.showLabel.text = @"暂无关注我的人";
            cell.showImageView.image = [UIImage imageNamed:@"icon_warn_follow"];
        }
        return cell;
    }else{
        static NSString *cellID = @"AttionViewCell";
        AttentionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([AttentionCell class])];
        }
        ChartModel *coffModel = self.dataArray[indexPath.row];
        [cell exchangeCardBtn:coffModel type:self.typeIndex];
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 6)];
        headerView.backgroundColor = [UIColor colorWithHexString:@"EFEFF4"];
        self.tableView.tableHeaderView = headerView;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 52.5, WIDTH, 0.5)];
        lineView.backgroundColor = [UIColor colorWithHexString:@"D9D9D9"];
        [cell.contentView addSubview:lineView];
        cell.atteneionDelegate = self;
        cell.index = indexPath.row;
        return cell;
    }
}

#pragma mark - --- AttentionCellDelegate
- (void)exchangeAttionAction:(NSInteger)index{
    ChartModel *coffModel = self.dataArray[index];
    if (self.typeIndex == 1) {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle: nil                                                                             message: nil                                                                       preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction: [UIAlertAction actionWithTitle: @"取消关注" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self cancleAttion:coffModel.userid];
            
        }]];
        [alertController addAction: [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController: alertController animated: YES completion: nil];
    }else{
        if (coffModel.isattent.integerValue == 0) {
            
            //    //诸葛监控
            [[AppDelegate shareInstance] setZhugeTrack:@"关注用户" properties:@{@"useID":coffModel.userid, @"company":[CommonMethod paramStringIsNull:coffModel.company],@"position":[CommonMethod paramStringIsNull:coffModel.position]}];
            [self attentionHer:coffModel.userid];
        }else{
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle: nil                                                                             message: nil                                                                       preferredStyle:UIAlertControllerStyleActionSheet];
            [alertController addAction: [UIAlertAction actionWithTitle: @"取消关注" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [self cancleAttion:coffModel.userid];
                
            }]];
            [alertController addAction: [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleCancel handler:nil]];
            
            [self presentViewController: alertController animated: YES completion: nil];
        }
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.netWorkStat == YES || self.dataArray.count == 0){
        [self getAttionTaCofferInformation:self.currentPag];
        return;
    }
    ChartModel *coffModel = self.dataArray[indexPath.row];
    NewMyHomePageController *home = [[NewMyHomePageController alloc]init];
    home.userId = coffModel.userid;
    [self.navigationController pushViewController:home animated:YES];
    
}

#pragma mark -------- 关注他
- (void)attentionHer:(NSNumber*)userId{
    [self attentionBtnAction:[NSString stringWithFormat:@"%@",[DataModelInstance shareInstance].userModel.userId] other:[NSString stringWithFormat:@"%@",userId] type:YES];
    @weakify(self);
    self.attentionBtnActionSuccess = ^(){
        @strongify(self);
        [self getAttionTaCofferInformation:self.currentPag];
    };
}

- (void)cancleAttion:(NSNumber *)useid{
    [self attentionBtnAction:[NSString stringWithFormat:@"%@",[DataModelInstance shareInstance].userModel.userId] other:[NSString stringWithFormat:@"%@",useid] type:NO];
    @weakify(self);
    self.attentionBtnActionSuccess = ^(){
        @strongify(self);
        [self getAttionTaCofferInformation:self.currentPag];
    };
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
