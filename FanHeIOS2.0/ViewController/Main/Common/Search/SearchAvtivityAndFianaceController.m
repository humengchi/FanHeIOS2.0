//
//  SearchAvtivityAndFianaceController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/20.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "SearchAvtivityAndFianaceController.h"
#import "PositionSearch.h"
#import "ActivityAndTopicOrFianaceCell.h"
#import "ActivityDetailController.h"
#import "TopicViewController.h"
#import "SearchActivityPlaceController.h"
#import "InformationDetailController.h"

@interface SearchAvtivityAndFianaceController ()<PositionSearchDelegate>{
    BOOL _isRefresh;
}

@property (nonatomic ,assign) NSInteger page;
@property (nonatomic ,strong) NSMutableArray *dataArray;
@property (nonatomic, assign) BOOL noNetWork;
@property (nonatomic, assign) BOOL handRefresh;
@property (nonatomic ,strong) PositionSearch *searchView;

@end

@implementation SearchAvtivityAndFianaceController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.page = 1;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, -64, WIDTH, 64)];
    view.backgroundColor = kDefaultColor;
    [self.view addSubview:view];
    
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self.tableView tableViewAddUpLoadRefreshing:^{
        self.page ++;
        self.handRefresh = YES;
        [self getActivityData:self.page];
    }];
    [self initSearchBar];
    if(self.searchText.length){
        self.searchBar.text = self.searchText;
        self.handRefresh = NO;
        [self getActivityData:self.page];
    }
    [self loadHotTagsData];
}

- (void)initSearchBar{
    if(!self.isHideNavBack){
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, 20, 44, 44);
        [backBtn setImage:kImageWithName(@"btn_tab_back") forState:UIControlStateNormal];
        [backBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [backBtn addTarget:self action:@selector(navBackButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:backBtn];
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(44, 20, WIDTH-44-55, 44)];
    }else{
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 20, WIDTH-55, 44)];
    }
    [self.searchBar becomeFirstResponder];
    self.searchBar.showsCancelButton = NO;
    self.searchBar.returnKeyType = UIReturnKeySearch;
    self.searchBar.enablesReturnKeyAutomatically = YES;
    self.searchBar.delegate = self;
    self.searchBar.barTintColor = HEX_COLOR(@"818C9E");
    [self.searchBar setPlaceholder:@"搜索"];
    [self.searchBar setSearchTextPositionAdjustment:UIOffsetMake(5, 0)];
    [self.searchBar setBackgroundColor:WHITE_COLOR];
    [self.searchBar setBackgroundImage:kImageWithColor(WHITE_COLOR, self.searchBar.bounds)];
    [self.searchBar setSearchFieldBackgroundImage:[kImageWithName(@"searchBackground") imageWithColor:HEX_COLOR(@"EFEFF4")] forState:UIControlStateNormal];
    [self.searchBar setSearchFieldBackgroundImage:[kImageWithName(@"searchBackground") imageWithColor:HEX_COLOR(@"EFEFF4")] forState:UIControlStateDisabled];
    [self.view addSubview:self.searchBar];
    
    if (self.type == SearchResult_Topic) {
        [self.searchBar setImage:[UIImage imageNamed:@"icon_search_topic"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
        [self.searchBar setPlaceholder:@"搜索话题"];
    }else if (self.type == SearchResult_Activity){
        [self.searchBar setImage:[UIImage imageNamed:@"icon_search_event"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
        [self.searchBar setPlaceholder:@"搜索活动"];
    }else if (self.type == SearchResult_Post){
        [self.searchBar setPlaceholder:@"搜索文章"];
    }
    
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancleBtn.frame = CGRectMake(WIDTH-60, 20, 60, 44);
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:HEX_COLOR(@"AFB6C1") forState:UIControlStateNormal];
    [cancleBtn addTarget:self action:@selector(backRootVC) forControlEvents:UIControlEventTouchUpInside];
    cancleBtn.titleLabel.font = FONT_SYSTEM_SIZE(16);
    [self.view addSubview:cancleBtn];
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, WIDTH, 0.5)];
    lineLabel.backgroundColor = kCellLineColor;
    [self.view addSubview:lineLabel];
    
}

#pragma mark - 网络请求标签
- (void)loadHotTagsData{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    if (self.type == SearchResult_Topic) {
        [requestDict setObject:@"/subject" forKey:@"param"];
    }else if (self.type == SearchResult_Post) {
        [requestDict setObject:@"/post" forKey:@"param"];
    }else{
        [requestDict setObject:@"/activity" forKey:@"param"];
    }
    [self requstType:RequestType_Get apiName:API_NAME_GET_AJAX_GET_HOT_SEARCH paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:responseObject[@"data"]];
            if(array.count){
                weakSelf.searchView = [[PositionSearch alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
                weakSelf.searchView.positionSearchDelegate = self;
                if (weakSelf.type == SearchResult_Topic || weakSelf.type == SearchResult_Post) {
                    [weakSelf.searchView createrTagSearchViewCity:array tag:2];
                }else if (weakSelf.type == SearchResult_Activity){
                    [weakSelf.searchView createrTagSearchViewCity:array tag:1];
                }
                if(weakSelf.dataArray.count==0&&!_isRefresh){
                    weakSelf.tableView.tableHeaderView = weakSelf.searchView;
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

#pragma mark - 网络请求
- (void)getActivityData:(NSInteger)page{
    _noNetWork = NO;
    self.tableView.tableHeaderView = [UIView new];
    if(self.handRefresh==NO){
        if(self.dataArray==nil){
            self.dataArray = [NSMutableArray new];
        }
        _isRefresh = YES;
        [self.dataArray removeAllObjects];
        [self.tableView reloadData];
    }
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    NSString *searchType;
    if(self.type==SearchResult_Post){
        searchType = @"post";
    }else if(self.type==SearchResult_Topic){
        searchType = @"subject";
    }else{
        searchType = @"activity";
    }
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@/%@/%ld",[DataModelInstance shareInstance].userModel.userId,self.searchBar.text,searchType,(long)page] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_AJAX_SEARCH paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if(weakSelf.dataArray==nil){
            weakSelf.dataArray = [NSMutableArray new];
        }
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:responseObject[@"data"]];
            for(NSDictionary *dict in array){
                SearchModel *model = [[SearchModel alloc] initWithDict:dict];
                [weakSelf.dataArray addObject:model];
            }
            if(array.count){
                [weakSelf.tableView.mj_footer endRefreshing];
            }else{
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
        _isRefresh = NO;
        weakSelf.tableView.tableHeaderView = [UIView new];
        [weakSelf.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        if(weakSelf.dataArray==nil){
            weakSelf.dataArray = [NSMutableArray new];
        }
        _isRefresh = NO;
        _noNetWork = YES;
        weakSelf.tableView.tableHeaderView = [UIView new];
        [weakSelf.tableView reloadData];
    }];
}

- (void)backRootVC{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark - UITableViewDelegate/Data
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.dataArray==nil||(self.dataArray.count==0&&self.searchBar.text.length==0)){
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
        return [ActivityAndTopicOrFianaceCell backActivityAndTopicOrFianaceCellHeigth:model searchType:self.type];
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
        [cell tranferActivityAndTopicOrFianaceCellModel:model searchText:self.searchBar.text searchType:self.type];
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
        }else if(_isRefresh){
            errorStr = @"正在加载中...";
        }else{
            errorStr = @"没有找到相关搜索";
        }
        UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake((WIDTH-250)/2, 28, 250, 19) backColor:kTableViewBgColor textColor:HEX_COLOR(@"AFB6C1") test:errorStr font:17 number:1 nstextLocat:NSTextAlignmentCenter];
        [cell.contentView addSubview:contentLabel];
        cell.backgroundColor = kTableViewBgColor;
        
        if(_isRefresh){
            CGFloat width = [NSHelper widthOfString:errorStr font:FONT_SYSTEM_SIZE(17) height:19];
            UIImageView *hudImageView = [[UIImageView alloc] initWithFrame:CGRectMake((WIDTH-width)/2-35, 27, 31, 21)];
            [hudImageView setAnimationImages:@[kImageWithName(@"loading_toutiao_p1"), kImageWithName(@"loading_toutiao_p2"), kImageWithName(@"loading_toutiao_p3")]];
            [hudImageView setAnimationDuration:1.f];
            [hudImageView setAnimationRepeatCount:0];
            [hudImageView startAnimating];
            [cell.contentView addSubview:hudImageView];
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(_noNetWork){
        self.handRefresh = YES;
        [self getActivityData:1];
    }else if(self.dataArray.count){
        SearchModel *model = self.dataArray[indexPath.row];
        if(self.type == SearchResult_Topic){
            TopicViewController *vc = [[TopicViewController alloc] init];
            vc.subjectId = model.rid;
            [self.navigationController pushViewController:vc animated:YES];
        }else if(self.type == SearchResult_Post){
            InformationDetailController *vc = [[InformationDetailController alloc] init];
            vc.postID = model.rid;
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            ActivityDetailController *vc = [[ActivityDetailController alloc] init];
            vc.activityid = model.rid;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark -- SearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self.tableView.mj_footer resetNoMoreData];
    if(searchText.length){
        self.page = 1;
        [self.dataArray removeAllObjects];
        self.handRefresh = NO;
        [self getActivityData:self.page];
        [self.tableView tableViewAddUpLoadRefreshing:^{
            self.page ++;
            self.handRefresh = YES;
            [self getActivityData:self.page];
        }];
    }else{
        self.page = 1;
        [self.dataArray removeAllObjects];
        [self.tableView reloadData];
        if(self.searchView){
            self.tableView.tableHeaderView = self.searchView;
        }
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}

#pragma mark - method
- (void)navBackButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -PositionSearchDelegate
- (void)gotoMakeSurePositionSearch:(NSString *)strPosition{
    self.page = 1;
    self.searchBar.text = strPosition;
    [self getActivityData:self.page];
    [self.tableView tableViewAddUpLoadRefreshing:^{
        self.page ++;
        self.handRefresh = YES;
        [self getActivityData:self.page];
    }];
}

- (void)gotoAddressSearch:(NSInteger)index{
    SearchActivityPlaceController *vc = [[SearchActivityPlaceController alloc] init];
    if (index == 1) {
        vc.placeStr = @"泛合金融咖啡";
    }else if (index == 2) {
        vc.placeStr = @"Blue Tree";
    }
    [self.navigationController pushViewController:vc animated:YES];
}

@end
