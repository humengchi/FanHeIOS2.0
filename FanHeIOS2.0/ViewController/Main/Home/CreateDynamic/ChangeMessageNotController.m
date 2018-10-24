//
//  ChangeMessageNotController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/7/20.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ChangeMessageNotController.h"
#import "NONetWorkTableViewCell.h"
#import "ChangeInformationMsgCell.h"

@interface ChangeMessageNotController ()
@property (nonatomic ,strong)NSMutableArray *dataArray;
@property (nonatomic ,assign) NSInteger currage;

@property (nonatomic ,assign) BOOL netWorkStat;
@end

@implementation ChangeMessageNotController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.netWorkStat = NO;
    self.currage = 1;
    self.dataArray = [NSMutableArray new];
    [self createCustomNavigationBar:@"通知"];
    [self getChanegNoteionList:self.currage];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //    [self.tableView tableViewAddUpLoadRefreshing:^{
    //        self.currage ++;
    //        [self getChanegNoteionList:self.currage];
    //    }];
    // Do any additional setup after loading the view from its nib.
}
#pragma MARK -------修改通知
- (void)getChanegNoteionList:(NSInteger)currage{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@",[DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_USER_EDIT_LIST paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [weakSelf.tableView endRefresh];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            for (NSDictionary *dic in array) {
                DynamicDetailModel *model = [[DynamicDetailModel alloc]init];
                [model setValuesForKeysWithDictionary:dic];
                [self.dataArray addObject:model];
            }
            
            [self.tableView reloadData];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [weakSelf.tableView endRefresh];
    }];
}
#pragma mark - UITableViewDelegate/DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.netWorkStat == YES && self.dataArray.count == 0 ){
        return 1;
    }else{
        return self.dataArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES && self.dataArray.count == 0){
        return self.tableView.frame.size.height;
    }else{
        return 92;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES && self.dataArray.count == 0 ){
        static NSString *cellID = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([NONetWorkTableViewCell class])];
        }
        self.tableView.tableHeaderView = [UIView new];
        return cell;
    }else{
        DynamicDetailModel *model = self.dataArray[indexPath.row];
        static NSString *cellID = @"ChangeInformationMsgCell";
        ChangeInformationMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([ChangeInformationMsgCell class])];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        
        [cell tranferChangeNotificationCellModel:model];
        return cell;
        
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(self.netWorkStat == YES && self.dataArray.count == 0 ){
        [self getChanegNoteionList:1];
        
    }else{
        DynamicDetailModel *model = self.dataArray[indexPath.row];
        NewMyHomePageController *newCtr = [[NewMyHomePageController alloc]init];
        newCtr.userId = model.userid;
        [self.navigationController pushViewController:newCtr animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
