//
//  SearchFriendListViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/22.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//
#import "SearchFriendViewController.h"
#import "SearchViewController.h"
#import "SearchFriendListViewController.h"
#import "SearchFriendTableViewCell.h"
#import "BaseTabbarViewController.h"

@interface SearchFriendListViewController (){
    BOOL _noNetWork;
    NSInteger _currentPage;
    BOOL _isRefresh;
}

@property (nonatomic, strong) NSMutableArray    *dataArray;

@end

@implementation SearchFriendListViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if([self.searchType isEqualToString:@"users"]){
        self.searchType = @"user";
    }else if([self.searchType isEqualToString:@"friend"]){
        self.searchType = @"friend";
    }
    _currentPage = 1;
    
    self.dataArray = [NSMutableArray array];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 20, 44, 44);
    [backBtn setImage:kImageWithName(@"btn_tab_back") forState:UIControlStateNormal];
    [backBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [backBtn addTarget:self action:@selector(navBackButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    [self initSearchBar];
    self.searchBar.text = self.searchStr;
    
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView tableViewAddUpLoadRefreshing:^{
        [self loadResultDataHttp:YES];
    }];
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, WIDTH, 0.5)];
    lineLabel.backgroundColor = kCellLineColor;
    [self.view addSubview:lineLabel];
    
    [self loadResultDataHttp:NO];
}

#pragma mark--返回按钮
- (void)navBackButtonClicked:(UIButton*)btn{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initSearchBar{
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(44, 20, WIDTH-44-55, 44)];
    self.searchBar.showsCancelButton = NO;
    self.searchBar.returnKeyType = UIReturnKeySearch;
    self.searchBar.enablesReturnKeyAutomatically = YES;
    self.searchBar.delegate = self;
    self.searchBar.barTintColor = HEX_COLOR(@"818C9E");
    [self.searchBar setPlaceholder:@"搜索擅长业务/姓名/手机号"];
    [self.searchBar setImage:[UIImage imageNamed:@"icon_search_people"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [self.searchBar setSearchTextPositionAdjustment:UIOffsetMake(5, 0)];
    [self.searchBar setBackgroundColor:WHITE_COLOR];
    [self.searchBar setBackgroundImage:kImageWithColor(WHITE_COLOR, self.searchBar.bounds)];
    [self.searchBar setSearchFieldBackgroundImage:[kImageWithName(@"searchBackground") imageWithColor:HEX_COLOR(@"EFEFF4")] forState:UIControlStateNormal];
    [self.searchBar setSearchFieldBackgroundImage:[kImageWithName(@"searchBackground") imageWithColor:HEX_COLOR(@"EFEFF4")] forState:UIControlStateDisabled];
    [self.view addSubview:self.searchBar];
    
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancleBtn.frame = CGRectMake(WIDTH-60, 20, 60, 44);
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:HEX_COLOR(@"e24943") forState:UIControlStateNormal];
    [cancleBtn addTarget:self action:@selector(backRootVC) forControlEvents:UIControlEventTouchUpInside];
    cancleBtn.titleLabel.font = FONT_SYSTEM_SIZE(16);
    [self.view addSubview:cancleBtn];
}

- (void)backRootVC{
    NSMutableArray *vcArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    for(int i=self.navigationController.viewControllers.count-1; i>0;i--){
        id vc = self.navigationController.viewControllers[i];
        if([vc isKindOfClass:[SearchViewController class]]||[vc isKindOfClass:[SearchFriendViewController class]]||[vc isKindOfClass:[SearchFriendListViewController class]]){
            [vcArray removeObjectAtIndex:i];
        }else{
            break;
        }
    }
    if([vcArray.lastObject isKindOfClass:[BaseTabbarViewController class]]){
        [self.navigationController setViewControllers:vcArray animated:NO];
    }else{
        [self.navigationController setViewControllers:vcArray animated:YES];
    }
}

#pragma mark - 网络请求数据
- (void)loadResultDataHttp:(BOOL)handRefresh{
    _noNetWork = NO;
    if(handRefresh==NO){
        _isRefresh = YES;
        [self.dataArray removeAllObjects];
        [self.tableView reloadData];
    }
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@/%@/%ld",[DataModelInstance shareInstance].userModel.userId,self.searchBar.text,self.searchType,(long)_currentPage] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_AJAX_SEARCH paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:responseObject[@"data"]];
            for(NSDictionary *dict in array){
                SearchModel *model = [[SearchModel alloc] initWithDict:dict];
                [weakSelf.dataArray addObject:model];
            }
            if(array.count){
                _currentPage++;
                [weakSelf.tableView.mj_footer endRefreshing];
            }else{
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
        _isRefresh = NO;
        [weakSelf.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        _isRefresh = NO;
        _noNetWork = YES;
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - UITableViewDelegate/Data
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.dataArray.count){
        return self.dataArray.count;
    }else if(self.searchBar.text.length==0){
        return 0;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.dataArray.count){
        return 85;
    }else{
        return 120;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.dataArray.count){
        static NSString *identify = @"SearchFriendTableViewCell";
        SearchFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"SearchFriendTableViewCell"];
        }
        SearchModel *model = self.dataArray[indexPath.row];
        if([self.searchType isEqualToString:@"user"]){
            [cell updateDisplaySearch:model showAddBtn:YES searchText:self.searchBar.text];
        }else{
            [cell updateDisplaySearch:model showAddBtn:NO searchText:self.searchBar.text];
        }
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
        [self loadResultDataHttp:YES];
    }else if(self.dataArray.count){
        [self.view endEditing:YES];
        SearchModel *model = self.dataArray[indexPath.row];
        NewMyHomePageController *myhome = [[NewMyHomePageController alloc]init];
        myhome.userId = model.rid;
        [self.navigationController pushViewController:myhome animated:YES];
    }
}

#pragma mark -- SearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if(searchText.length){
        _currentPage = 1;
        [self loadResultDataHttp:NO];
    }else{
        _currentPage = 1;
        [self.dataArray removeAllObjects];
        [self.tableView reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}

@end
