//
//  ActivityReportListController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/5/5.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ActivityReportListController.h"
#import "NONetWorkTableViewCell.h"
#import "ActivityReportListCell.h"
#import "InformationDetailController.h"
@interface ActivityReportListController ()
@property (nonatomic ,strong) NSMutableArray *dataArray;
@property (nonatomic,assign)  BOOL netWorkStat;
@property (nonatomic,assign)   NSInteger currentPag;
@property (nonatomic,strong)  ReportModel *reportModel;
@end

@implementation ActivityReportListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSMutableArray new];
    [self createCustomNavigationBar:@"活动报道"];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
 self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
 self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.currentPag = 1;
    [self.tableView tableViewAddDownLoadRefreshing:^{
        self.currentPag = 1;
        
        [self getMyActivityReportList:self.currentPag];
        
    }];
    [self.tableView tableViewAddUpLoadRefreshing:^{
        self.currentPag ++;
        [self getMyActivityReportList:self.currentPag];
    }];

    [self getMyActivityReportList:self.currentPag];
    
    // Do any additional setup after loading the view.
}
#pragma mark ------  获取报道列表
- (void)getMyActivityReportList:(NSInteger)page{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    self.tableView.tableFooterView = [UIView new];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%ld", (long)page] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_SUBJECTREPOIT_ACTIVITY_LIST paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        weakSelf.netWorkStat = NO;
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if (weakSelf.currentPag == 1) {
                [weakSelf.tableView endRefresh];
                [weakSelf.tableView.mj_footer resetNoMoreData];
                [weakSelf.dataArray removeAllObjects];
            }
            NSArray *array = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            if(array.count){
                [weakSelf.tableView endRefresh];
            }else{
                [weakSelf.tableView endRefreshNoData];
            }
            for (NSDictionary *subDic in array) {
              
                weakSelf.reportModel = [[ReportModel alloc] initWithDict:subDic];
                [weakSelf.dataArray addObject:weakSelf.reportModel];
            }
            [weakSelf.tableView reloadData];
        }else{
            [weakSelf.tableView endRefresh];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        weakSelf.netWorkStat = YES;
        [weakSelf.tableView endRefresh];
        [weakSelf.tableView reloadData];
    }];
    
}

#pragma mark - UITableViewDelegate/DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.netWorkStat == YES && self.dataArray.count == 0){
        return 1;
    }else {
        return self.dataArray.count;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES && self.dataArray.count == 0){
        return self.tableView.frame.size.height;
    }else {
    return 106;
    }
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES && self.dataArray.count == 0){
        static NSString *cellID = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([NONetWorkTableViewCell class])];
        }
        return cell;
    }else{
        static NSString *cellID = @"ActivityReportListCell";
        ActivityReportListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([ActivityReportListCell class])];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        self.reportModel = self.dataArray[indexPath.row];
        [cell tranferActivityReportModel:self.reportModel];
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
        self.reportModel = self.dataArray[indexPath.row];
        InformationDetailController *detail = [[InformationDetailController alloc]init];
        detail.postID = self.reportModel.postid;
        detail.startType = YES;
        [self.navigationController pushViewController:detail animated:YES];
        

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
