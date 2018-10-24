//
//  VistorsListViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/11/1.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "VistorsListViewController.h"
#import "LookHistoryCell.h"
#import "NODataTableViewCell.h"

@interface VistorsListViewController (){
    NSDate *_currentDate;
    NSInteger _currentPage;
}

@property (nonatomic, strong) NSMutableArray    *dataArray;

@end

@implementation VistorsListViewController


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
    _currentPage = 1;
    [self createCustomNavigationBar:@"看过我的人"];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 5)];
    lineLabel.backgroundColor = kTableViewBgColor;
    self.tableView.tableHeaderView = lineLabel;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView tableViewAddUpLoadRefreshing:^{
        [self loadHttpData];
    }];
    [self loadHttpData];
}

#pragma mark - 网络请求
- (void)loadHttpData{
    if(_currentDate == nil){
        _currentDate = [NSDate date];
    }
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@/%ld", [DataModelInstance shareInstance].userModel.userId, [NSDate stringFromDate:_currentDate format:kTimeFormat], (long)_currentPage++] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_VISITORS paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if(weakSelf.dataArray == nil){
            weakSelf.dataArray = [NSMutableArray array];
        }
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *subArray = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            for (NSDictionary *subDic in subArray) {
                LookHistoryModel *model = [[LookHistoryModel alloc] initWithDict:subDic];
                [weakSelf.dataArray addObject:model];
            }
            if(subArray.count != 20 && weakSelf.dataArray.count != 0){
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            }else{
                [weakSelf.tableView.mj_footer endRefreshing];
            }
            [weakSelf.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        if(weakSelf.dataArray == nil){
            weakSelf.dataArray = [NSMutableArray array];
        }
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.dataArray == nil){
        return 0;
    }else if(self.dataArray.count){
        return self.dataArray.count;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.dataArray.count){
        return 74;
    }else{
        return self.tableView.frame.size.height;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.dataArray.count){
        static NSString *identify = @"LookHistoryCell";
        LookHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"LookHistoryCell"];
        }
        LookHistoryModel *model = self.dataArray[indexPath.row];
        cell.isMyPage = YES;
        [cell lookHistoryModel:model];
        return cell;
    }else{
        static NSString *identify = @"NODataTableViewCell";
        NODataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"NODataTableViewCell"];
        }
        cell.mainLabel.text = @"近期没有访客";
        cell.subLabel.text = @"";
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.dataArray.count){
    LookHistoryModel *model = self.dataArray[indexPath.row];
    NewMyHomePageController *vc = [[NewMyHomePageController alloc] init];
    vc.userId = model.userid;
    [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
