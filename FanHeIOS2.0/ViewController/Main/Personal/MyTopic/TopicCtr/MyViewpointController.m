//
//  MyViewpointController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/20.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "MyViewpointController.h"
#import "DelectDataView.h"
#import "MyStartCell.h"
#import "NONetWorkTableViewCell.h"
#import "TopicViewController.h"
#import "InformationDetailController.h"
#import "DelectTopicCell.h"
@interface MyViewpointController ()
@property   (nonatomic ,assign) BOOL netWorkStat;
@property   (nonatomic ,strong) DelectDataView *delectView;
@property   (nonatomic ,assign) NSInteger currentPag;
@property   (nonatomic ,strong) NSMutableArray *viewPointArray;
@property   (nonatomic ,strong)MyTopicModel *model;
@end

@implementation MyViewpointController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewPointArray = [NSMutableArray new];
    if (self.userID.integerValue > 0) {
        if (self.userID.integerValue == [DataModelInstance shareInstance].userModel.userId.integerValue) {
            [self createCustomNavigationBar:@"我的观点&评论"];
        }else{
            [self createCustomNavigationBar:@"Ta的观点&评论"];
        }
    }else{
        [self createCustomNavigationBar:@"我的观点&评论"];
    }
    
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.currentPag = 1;
    [self getMyStartViewPoint:self.currentPag];
    [self.tableView tableViewAddDownLoadRefreshing:^{
        self.currentPag = 1;
        [self getMyStartViewPoint:self.currentPag];
    }];
    [self.tableView tableViewAddUpLoadRefreshing:^{
        self.currentPag ++;
        [self getMyStartViewPoint:self.currentPag];
    }];
    
}
#pragma mark ------  获取我的观点列表数据
- (void)getMyStartViewPoint:(NSInteger)page{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    if (self.userID.integerValue > 0) {
        if (self.userID.integerValue == [DataModelInstance shareInstance].userModel.userId.integerValue) {
            [requestDict setObject:[NSString stringWithFormat:@"/%@/%@/%ld",[DataModelInstance shareInstance].userModel.userId,[DataModelInstance shareInstance].userModel.userId, page] forKey:@"param"];
        }else{
            [requestDict setObject:[NSString stringWithFormat:@"/%@/%@/%ld",self.userID,[DataModelInstance shareInstance].userModel.userId, (long)page] forKey:@"param"];
        }
    }else{
        [requestDict setObject:[NSString stringWithFormat:@"/%@/%@/%ld",[DataModelInstance shareInstance].userModel.userId,[DataModelInstance shareInstance].userModel.userId, (long)page] forKey:@"param"];
    }
    NSString *apiType  = API_NAME_MYTOPIC_MYVIOWPOINT;
    [self requstType:RequestType_Get apiName:apiType paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [weakSelf.tableView endRefresh];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if (self.currentPag == 1) {
                [self.viewPointArray removeAllObjects];
            }
            NSArray *array = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            for (NSDictionary *dict in array) {
                weakSelf.model = [[MyTopicModel alloc] initWithDict:dict];
                weakSelf.model.isViewPoint = YES;
                [weakSelf.viewPointArray addObject:weakSelf.model];
            }
            if (weakSelf.viewPointArray.count == 0) {
                [weakSelf notStartPiontNewDetail];
            }else{
                [weakSelf.tableView reloadData];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [weakSelf.tableView endRefresh];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        [weakSelf.tableView reloadData];
    }];
}
#pragma mark ---你还没有发布任何观点&评论
- (void)notStartPiontNewDetail{
    [self.tableView removeFromSuperview];
    self.delectView = [CommonMethod getViewFromNib:NSStringFromClass([DelectDataView class])];
    self.delectView.frame = CGRectMake(0, 64, WIDTH, HEIGHT);
    self.delectView.coverImageView.image = kImageWithName(@"icon_mytopic_nocomment");
    self.delectView.showTitleLabel.text = @"你还没有发布任何观点&评论";
    [self.view addSubview:self.delectView];
}
#pragma mark - UITableViewDelegate/DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.netWorkStat == YES){
        return 1;
    }
    return self.viewPointArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES){
        return self.tableView.frame.size.height;
    }
    self.model = self.viewPointArray[indexPath.row];
    if (self.model.gid.integerValue == 0) {
    return  [DelectTopicCell backDelectTopicCellHeigthMyTopicModel: self.model];
    }else{
        return  [MyStartCell backMyStartCellHeigthMyTopicModel:self.model];
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat){
        static NSString *cellID = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([NONetWorkTableViewCell class])];
        }
        self.tableView.tableHeaderView = [UIView new];
        return cell;
    }else{
        self.model = self.viewPointArray[indexPath.row];
        if (self.model.gid.integerValue == 0) {
            static NSString *cellID = @"DelectTopicCell";
            DelectTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [CommonMethod getViewFromNib:NSStringFromClass([DelectTopicCell class])];
            }
            
            [cell tranferDelectTopicCellMyTopicModel:self.model uiseID:self.userID];
            cell.selectionStyle = UITableViewCellAccessoryNone;
            self.tableView.tableHeaderView = [UIView new];
            return cell;
        }else{
            static NSString *cellID = @"MyStartCell";
            MyStartCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [CommonMethod getViewFromNib:NSStringFromClass([MyStartCell class])];
            }
            
            [cell tranferMyStartCellMyTopicModel:self.model];
            cell.selectionStyle = UITableViewCellAccessoryNone;
            self.tableView.tableHeaderView = [UIView new];
            return cell;
        }
        
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
