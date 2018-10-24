//
//  ViewpointListViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/15.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ViewpointListViewController.h"
#import "TopicTableViewCell.h"
#import "ViewpointDetailViewController.h"
#import "NONetWorkTableViewCell.h"
#import "NODataTableViewCell.h"

@interface ViewpointListViewController (){
    BOOL _isShowMenuView;
    NSInteger _currentPage;
    BOOL _noNetWork;
}

@property (nonatomic, strong) NSMutableArray *listArray;

@end

@implementation ViewpointListViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentPage = 1;
    [self createCustomNavigationBar:@"好友观点"];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView tableViewAddUpLoadRefreshing:^{
        [self loadViewpointHttpData];
    }];
    [self loadViewpointHttpData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 网络请求列表
- (void)loadViewpointHttpData{
    _noNetWork = NO;
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@/%ld",self.tdModel.subjectid, [DataModelInstance shareInstance].userModel.userId, (long)_currentPage] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_POST_FRIEND_VIEWPOINT paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if(weakSelf.listArray==nil){
            weakSelf.listArray = [NSMutableArray array];
        }
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:responseObject[@"data"]];
            for(NSDictionary *dict in array){
                ViewpointModel *model = [[ViewpointModel alloc] initWithDict:dict];
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
    if(self.listArray == nil){
        return 0;
    }else if(self.listArray.count){
        return self.listArray.count;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.listArray.count){
        ViewpointModel *model = self.listArray[indexPath.row];
        return model.cellHeight;
    }else{
        return self.tableView.frame.size.height;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.listArray.count){
        static NSString *identify = @"TopicTableViewCell";
        TopicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"TopicTableViewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell updateDisplay:self.listArray[indexPath.row]];
        __weak typeof(self) weakSelf = self;
        cell.selectCell = ^(UITapGestureRecognizer *tap){
            CGPoint point = [tap locationInView:weakSelf.tableView];
            [weakSelf tableView:weakSelf.tableView didSelectRowAtIndexPath:[weakSelf.tableView indexPathForRowAtPoint:point]];
        };
        return cell;
    }else if(_noNetWork){
        static NSString *identify = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"NONetWorkTableViewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }else{
        static NSString *identify = @"NODataTableViewCell";
        NODataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"NODataTableViewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.mainLabel.text = @"暂无好友观点";
        cell.subLabel.text = @"";
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.listArray.count){
        ViewpointModel *vpModel = self.listArray[indexPath.row];;
        ViewpointDetailViewController *vc = [CommonMethod getVCFromNib:[ViewpointDetailViewController class]];
        vc.viewpointId = vpModel.reviewid;
        vc.topicDetailModel = self.tdModel;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [self loadViewpointHttpData];
    }
}

@end
