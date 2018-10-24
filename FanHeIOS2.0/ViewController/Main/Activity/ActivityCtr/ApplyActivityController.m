//
//  ApplyActivityController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/5.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ApplyActivityController.h"
#import "LookHistoryCell.h"
#import "NONetWorkTableViewCell.h"

@interface ApplyActivityController ()
@property (nonatomic ,strong) NSMutableArray *dataArray;
@property (nonatomic,assign)  BOOL netWorkStat;
@property (nonatomic ,assign) NSInteger currentPage;
@end

@implementation ApplyActivityController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar:@"已报名"];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.currentPage = 1;
     [self getApplyList:self.currentPage];
    [self.tableView tableViewAddDownLoadRefreshing:^{
        self.currentPage = 1;
        [self getApplyList:self.currentPage];
    }];
    [self.tableView tableViewAddUpLoadRefreshing:^{
        self.currentPage ++;
         [self getApplyList:self.currentPage];
    }];
   

    // Do any additional setup after loading the view from its nib.
}
#pragma mark - 网络请求
- (void)getApplyList:(NSInteger)page{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
  [requestDict setObject:[NSString stringWithFormat:@"/%@/%ld/0",self.activityID,(long)page] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_ACTIVITY_APPLY_LISTNEW paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        self.netWorkStat = NO;
        if(weakSelf.dataArray == nil){
            weakSelf.dataArray = [NSMutableArray array];
        }
        if (page == 1) {
            [weakSelf.dataArray removeAllObjects];
        }
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *subArray = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            for (NSDictionary *subDic in subArray) {
                LookHistoryModel *model = [[LookHistoryModel alloc] initWithDict:subDic];
                [weakSelf.dataArray addObject:model];
            }
            [weakSelf.tableView.mj_header endRefreshing];
            [weakSelf.tableView.mj_footer endRefreshing];
            [weakSelf.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
       self.netWorkStat = YES;
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.netWorkStat == YES){
        return 1;
    }else {
        return self.dataArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES){
        return self.tableView.frame.size.height;
    }else{
        return 74;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES ){
        static NSString *cellID = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([NONetWorkTableViewCell class])];
        }
        return cell;
    }else{
        static NSString *identify = @"LookHistoryCell";
        LookHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"LookHistoryCell"];
        }
        cell.isApply = YES;
        LookHistoryModel *model = self.dataArray[indexPath.row];
        [cell lookHistoryModel:model];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.netWorkStat == YES) {
        [self getApplyList:1];
    }
    if(self.dataArray.count){
        LookHistoryModel *model = self.dataArray[indexPath.row];
        NewMyHomePageController *vc = [[NewMyHomePageController alloc] init];
        vc.userId = model.userid;
        [self.navigationController pushViewController:vc animated:YES];
    }
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
