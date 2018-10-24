//
//  SearchActivityPlaceController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/1/22.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "SearchActivityPlaceController.h"
#import "ActivityAndTopicOrFianaceCell.h"
#import "ActivityDetailController.h"

@interface SearchActivityPlaceController (){
    BOOL _noNetWork;
}

@property (nonatomic ,assign) NSInteger page;
@property (nonatomic ,strong) NSMutableArray *dataArray;
@property (nonatomic, assign) BOOL handRefresh;

@end

@implementation SearchActivityPlaceController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.handRefresh = YES;
    self.page = 1;
    [self createCustomNavigationBar:self.placeStr];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView tableViewAddUpLoadRefreshing:^{
        self.page ++;
        [self getMyActivityList:self.page];
    }];
    [self getMyActivityList:self.page];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ------  获取活动列表
- (void)getMyActivityList:(NSInteger)page{
    _noNetWork = NO;
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud;
    if(self.handRefresh==YES){
        hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
        self.handRefresh = NO;
    }
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%ld/%@", page, ([self.placeStr isEqualToString:@"泛合金融咖啡"]?@(1):@(2))] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_ACTIVITY_ACTIVITY_LISTS paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if(weakSelf.dataArray==nil){
            weakSelf.dataArray = [NSMutableArray array];
        }
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            if(array.count){
                [weakSelf.tableView endRefresh];
            }else{
                [weakSelf.tableView endRefreshNoData];
            }
            for (NSDictionary *dict in array) {
                SearchModel *model = [[SearchModel alloc] initWithDict:dict];
                model.rid = [CommonMethod paramNumberIsNull:dict[@"activityid"]];
                [weakSelf.dataArray addObject:model];
            }
            [weakSelf.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        if(weakSelf.dataArray==nil){
            weakSelf.dataArray = [NSMutableArray array];
        }
        _noNetWork = YES;
        [hud hideAnimated:YES];
        [weakSelf.tableView endRefresh];
        [weakSelf.tableView reloadData];
    }];
    
}

#pragma mark - UITableViewDelegate/Data
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.dataArray==nil){
        return 0;
    }else if(self.dataArray.count){
        return self.dataArray.count;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.dataArray.count){
        SearchModel *model = self.dataArray[indexPath.row];
        return [ActivityAndTopicOrFianaceCell backActivityAndTopicOrFianaceCellHeigth:model searchType:SearchResult_Activity];
    }else{
        return 120;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.dataArray.count){
        static NSString *identify = @"ActivityAndTopicOrFianaceCell";
        ActivityAndTopicOrFianaceCell *cell =[tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"ActivityAndTopicOrFianaceCell"];
        }
        SearchModel *model = self.dataArray[indexPath.row];
        [cell tranferActivityAndTopicOrFianaceCellModel:model searchText:@"" searchType:SearchResult_Activity];
        return cell;
    }else{
        static NSString *identify = @"UITableViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        }
        for(UIView *view in cell.contentView.subviews){
            [view removeFromSuperview];
        }
        NSString *errorStr = @"";
        if(_noNetWork){
            errorStr = @"无法链接到网络，点击屏幕重试";
        }else{
            errorStr = @"没有找到相关搜索";
        }
        UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake((WIDTH-250)/2, 38, 250, 19) backColor:kTableViewBgColor textColor:HEX_COLOR(@"AFB6C1") test:errorStr font:17 number:1 nstextLocat:NSTextAlignmentCenter];
        [cell.contentView addSubview:contentLabel];
        cell.backgroundColor = kTableViewBgColor;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(_noNetWork){
        self.handRefresh = YES;
        [self getMyActivityList:1];
    }else if(self.dataArray.count){
        SearchModel *model = self.dataArray[indexPath.row];
        ActivityDetailController *vc = [[ActivityDetailController alloc] init];
        vc.activityid = model.rid;
        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end
