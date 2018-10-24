//
//  PraiseListViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/15.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "PraiseListViewController.h"
#import "LookHistoryCell.h"

@interface PraiseListViewController (){
    BOOL _isShowMenuView;
    NSInteger _currentPage;
    BOOL _noNetWork;
}

@property (nonatomic, strong) NSMutableArray *listArray;

@end

@implementation PraiseListViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createCustomNavigationBar:@"点赞"];
    _currentPage = 1;
    
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView tableViewAddUpLoadRefreshing:^{
        [self.tableView endRefresh];
    }];
    [self loadReviewListHttpData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadReviewListHttpData{
    _noNetWork = NO;
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%ld",self.reviewid, (long)_currentPage] forKey:@"param"];
    NSString *apiType;
    if (self.listType == YES) {
        if (self.dynamicType == YES) {
            apiType =API_NAME_GET_DYNAMICDETAILRATELIT_PARSEVIEWLIST;
        }else{
           apiType = API_NAME_RATEFINANACE_GETLIKELIST; 
        }
        
    }else{
        apiType = API_NAME_POST_PRAISE_LIST;
    }
    [self requstType:RequestType_Get apiName:apiType paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if(weakSelf.listArray==nil){
            weakSelf.listArray = [NSMutableArray array];
        }
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:responseObject[@"data"]];
            for(NSDictionary *dict in array){
                LookHistoryModel *model = [[LookHistoryModel alloc] initWithDict:dict];
                [weakSelf.listArray addObject:model];
            }
            if(array.count!=20){
                [weakSelf.tableView endRefreshNoData];
            }else{
                [weakSelf.tableView endRefresh];
            }
            _currentPage++;
            [weakSelf.tableView reloadData];
        }else{
            [weakSelf.tableView endRefresh];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [weakSelf.tableView endRefresh];
        if(weakSelf.listArray==nil){
            weakSelf.listArray = [NSMutableArray array];
        }
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark -- UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.listArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 74;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"LookHistoryCell";
    LookHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [CommonMethod getViewFromNib:@"LookHistoryCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    LookHistoryModel *model = self.listArray[indexPath.row];
    [cell lookHistoryModel:model];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LookHistoryModel *model = self.listArray[indexPath.row];
    NewMyHomePageController *vc = [[NewMyHomePageController alloc] init];
    vc.userId = model.userid;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
