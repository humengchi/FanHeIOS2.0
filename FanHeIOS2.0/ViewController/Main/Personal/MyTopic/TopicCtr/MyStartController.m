
//
//  MyStartController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/20.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "MyStartController.h"
#import "ToicpCharacterCell.h"
#import "NONetWorkTableViewCell.h"
#import "DelectDataView.h"
#import "TopicViewController.h"
@interface MyStartController ()
@property  (nonatomic ,assign) BOOL netWorkStat;
@property   (nonatomic ,strong) DelectDataView *delectView;
@property  (nonatomic ,strong)  NSMutableArray *startTopicArray;
@property (nonatomic ,strong) MyTopicModel * topicModel;
@property  (nonatomic ,assign)NSInteger currentPag;
@end

@implementation MyStartController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.startTopicArray = [NSMutableArray new];
      [self createCustomNavigationBar:@"我发起的话题"];
      [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.currentPag = 1;
    [self getMyAttionTopic:self.currentPag];
    [self.tableView tableViewAddDownLoadRefreshing:^{
        self.currentPag = 1;
        [self getMyAttionTopic:self.currentPag];
    }];
    [self.tableView tableViewAddUpLoadRefreshing:^{
        self.currentPag ++;
        [self getMyAttionTopic:self.currentPag];
    }];
}
#pragma mark ------  获取发起话题列表数据
- (void)getMyAttionTopic:(NSInteger)page{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];

      [requestDict setObject:[NSString stringWithFormat:@"/%@/%ld",[DataModelInstance shareInstance].userModel.userId, page] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_MYTOPIC_MYSTARTTOPIC paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
            [weakSelf.tableView endRefresh];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if (self.currentPag == 1) {
                [self.startTopicArray removeAllObjects];
            }
            NSArray *array = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            for (NSDictionary *dict in array) {
                weakSelf.topicModel = [[MyTopicModel alloc] initWithDict:dict];
                [weakSelf.startTopicArray addObject:weakSelf.topicModel];
            }
            if (weakSelf.startTopicArray.count == 0) {
                 [weakSelf notStartTopicNewDetail];
            }else{
                  [weakSelf.tableView reloadData];
            }
            [weakSelf.tableView.mj_header endRefreshing];
            [weakSelf.tableView.mj_footer endRefreshing];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
            [weakSelf.tableView endRefresh];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        [weakSelf.tableView reloadData];
    }];
    
}

#pragma mark -----你还没有发布的话题
- (void)notStartTopicNewDetail{
    [self.tableView removeFromSuperview];
    self.delectView = [CommonMethod getViewFromNib:NSStringFromClass([DelectDataView class])];
    self.delectView.frame = CGRectMake(0, 64, WIDTH, HEIGHT);
    self.delectView.coverImageView.image = kImageWithName(@"icon_mytopic_nonefaqi");
    self.delectView.showTitleLabel.text = @"你还没有发布的话题";
    [self.view addSubview:self.delectView];
}
#pragma mark - UITableViewDelegate/DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.netWorkStat == YES){
        return 1;
    }
        return self.startTopicArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES){
        return self.tableView.frame.size.height;
    }
    self.topicModel = self.startTopicArray[indexPath.row];
    
    return [ToicpCharacterCell backToicpCharacterCell:self.topicModel];

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
        static NSString *cellID = @"MyTopCell";
        ToicpCharacterCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([ToicpCharacterCell class])];
        }
        self.topicModel = self.startTopicArray[indexPath.row];
        cell.backgroundColor = [UIColor whiteColor];
        [cell tranferToicpCharacterCellMyTopicModel:self.topicModel];
        cell.selectionStyle = UITableViewCellAccessoryNone;
        self.tableView.tableHeaderView = [UIView new];
        return cell;
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.topicModel = self.startTopicArray[indexPath.row];
    TopicViewController *vc = [CommonMethod getVCFromNib:[TopicViewController class]];
    vc.subjectId = self.topicModel.subjectid;//@(628);//53
    [self.navigationController pushViewController:vc animated:YES];
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
