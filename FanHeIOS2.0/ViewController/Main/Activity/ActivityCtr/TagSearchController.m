//
//  TagSearchController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/5.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "TagSearchController.h"
#import "NONetWorkTableViewCell.h"
#import "TagSearchCell.h"
#import "NODataTableViewCell.h"
#import "ActivityDetailController.h"
@interface TagSearchController ()
@property (nonatomic ,strong) NSMutableArray *dataArray;
@property (nonatomic,assign)  BOOL netWorkStat;
@property (nonatomic ,assign) NSInteger currentPage;
@end

@implementation TagSearchController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSMutableArray new];
    [self createCustomNavigationBar:[NSString stringWithFormat:@"#%@#相关活动",self.tagStr]];
   
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.currentPage = 1;
    [self getTagList:self.currentPage];
    
    [self.tableView tableViewAddUpLoadRefreshing:^{
        self.currentPage ++;
        [self getTagList:self.currentPage];
    }];

}
#pragma mark - 网络请求
- (void)getTagList:(NSInteger)page{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%ld",self.tagStr,(long)page] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_ACTIVITYTAGSEARCH paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
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
                MyActivityModel *model = [[MyActivityModel alloc] initWithDict:subDic];
                [weakSelf.dataArray addObject:model];
            }
            if(subArray.count){
                [weakSelf.tableView endRefresh];
            }else{
                [weakSelf.tableView endRefreshNoData];
            }
            [weakSelf.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [weakSelf.tableView endRefresh];
        weakSelf.netWorkStat = YES;
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.netWorkStat == YES || self.dataArray.count == 0){
        return 1;
    }else {
        return self.dataArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES || self.dataArray.count  == 0){
        return self.tableView.frame.size.height;
    }else{
        MyActivityModel *model = self.dataArray[indexPath.row];
        return [TagSearchCell backTagSearchCellHeigth:model];
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
    }else if(self.dataArray.count > 0){
        static NSString *identify = @"LookHistoryCell";
        TagSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"TagSearchCell"];
        }
        cell.strTag = self.tagStr;
           MyActivityModel *model = self.dataArray[indexPath.row];
        [cell tranferTagSearchCellModel:model];
        return cell;
    }else{
        static NSString *identify = @"NODataTableViewCell";
        NODataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"NODataTableViewCell"];
        }
        cell.coverImageView.image = [UIImage imageNamed:@"icon_no_shaixuan_b"];
        cell.mainLabel.text = @"暂无相关搜索";
        cell.subLabel.text = @"";
        return cell;

    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.netWorkStat == YES) {
           [self getTagList:1];
    }
    if(self.dataArray.count){
          MyActivityModel *model = self.dataArray[indexPath.row];
        ActivityDetailController *activityDetail = [[ActivityDetailController alloc]init];
      
        activityDetail.activityid = model.activityid;
        
        [self.navigationController pushViewController:activityDetail animated:YES];
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
