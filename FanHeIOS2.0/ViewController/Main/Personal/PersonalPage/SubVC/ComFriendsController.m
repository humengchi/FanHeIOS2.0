



//
//  ComFriendsController.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/11/2.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ComFriendsController.h"
#import "LookHistoryCell.h"
#import "NONetWorkTableViewCell.h"

@interface ComFriendsController ()
@property (nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic,assign) BOOL netWorkStat;
@property (nonatomic,strong) LookHistoryModel *lookModel;
@property (nonatomic,assign) NSInteger currPage;
@end

@implementation ComFriendsController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currPage = 1;
    self.dataArray = [NSMutableArray new];
    [self createCustomNavigationBar:@"共同好友"];
    [self initTableView:CGRectMake(0,64, WIDTH,HEIGHT - 64)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, 6) backColor:@"EFEFF4"];
    [self getTaComFriendsInformation:self.currPage];
    [self.tableView tableViewAddDownLoadRefreshing:^{
        self.currPage = 1;
        [self.dataArray removeAllObjects];
        [self getTaComFriendsInformation:self.currPage];
        
    }];
    [self.tableView tableViewAddUpLoadRefreshing:^{
        self.currPage ++;
        [self getTaComFriendsInformation:self.currPage];
    }];
    
    
    // Do any additional setup after loading the view.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.netWorkStat == YES){
        return 1;
    }else {
       return self.dataArray.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES){
        return self.tableView.frame.size.height;
    }else {
        return 74;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat){
        static NSString *cellID = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([NONetWorkTableViewCell class])];
        }
        self.tableView.tableHeaderView = [UIView new];
        return cell;
    }else{
        static NSString *cellReID = @"cellReID";
        LookHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([LookHistoryCell class])];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.isMyPage = YES;
        self.lookModel = self.dataArray[indexPath.row];
        [cell lookHistoryModel:self.lookModel];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.lookModel = self.dataArray[indexPath.row];
    NewMyHomePageController *myHome = [[NewMyHomePageController alloc]init];
    myHome.userId = self.lookModel.userid;
    [self.navigationController pushViewController:myHome animated:YES];
}

#pragma mark --- 网络请求数据
- (void)getTaComFriendsInformation:(NSInteger)pager{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%ld/%ld", [DataModelInstance shareInstance].userModel.userId,(long)self.userID.integerValue,(long)pager] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_USER_GET_HIS_PEOPLE_COMMON_FRIEND paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        weakSelf.netWorkStat = NO;
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSLog(@"%@",responseObject);
            NSArray *subArray = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            for (NSDictionary *subDic in subArray) {
                weakSelf.lookModel = [[LookHistoryModel alloc] initWithDict:subDic];
                [self.dataArray addObject:weakSelf.lookModel];
            }
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            [self.tableView reloadData];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        
        
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        weakSelf.netWorkStat = YES;
        
        [weakSelf.tableView reloadData];
    }];
}

@end
