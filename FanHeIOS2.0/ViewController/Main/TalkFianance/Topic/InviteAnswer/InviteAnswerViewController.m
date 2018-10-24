//
//  InviteAnswerViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/15.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "InviteAnswerViewController.h"
#import "SearchFriendTableViewCell.h"
#import "NONetWorkTableViewCell.h"
#import "ZSSRichTextEditor.h"
#import "TopicViewController.h"

@interface InviteAnswerViewController (){
    BOOL _noNetWork;
    NSInteger _currentPage;
}

@property (nonatomic, strong) NSMutableArray *tableArray;
@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, strong) NSMutableArray *searchArray;

@end

@implementation InviteAnswerViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar:@""];
    [self initSearchBar];
    if(self.isCreateTopic){
        [self createCustomNavigationBar];
    }
    _currentPage = 1;
    
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self loadViewpointHttpData];
}

- (void)createCustomNavigationBar{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 64)];
    barView.backgroundColor = WHITE_COLOR;
    [self.view addSubview:barView];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(WIDTH-50, 20, 44, 44);
    [backBtn setTitle:@"完成" forState:UIControlStateNormal];
    [backBtn setTitleColor:HEX_COLOR(@"e24943") forState:UIControlStateNormal];
    backBtn.titleLabel.font = FONT_SYSTEM_SIZE(16);
    [backBtn addTarget:self action:@selector(finishButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [barView addSubview:backBtn];
    
    UILabel *titleLabel = [UILabel createLabel:CGRectMake(64, 20, WIDTH-128, 44) font:FONT_SYSTEM_SIZE(17) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"383838") ];
    titleLabel.text = @"邀请参与讨论";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [barView addSubview:titleLabel];
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 63.5, WIDTH, 0.5)];
    lineLabel.backgroundColor = kCellLineColor;
    [barView addSubview:lineLabel];
}

- (void)finishButtonClicked{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"publishOrEditTopicSaveSuccess" object:nil];
//    [self.navigationController popToRootViewControllerAnimated:YES];
    TopicViewController *vc = [CommonMethod getVCFromNib:[TopicViewController class]];
    vc.subjectId = self.tdModel.subjectid;
    [self.navigationController setViewControllers:[NSArray arrayWithObjects:self.navigationController.viewControllers.firstObject, vc, nil] animated:YES];
}

- (void)initSearchBar{
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(40, 20, WIDTH-56, 43)];
    self.searchBar.showsCancelButton = NO;
    self.searchBar.returnKeyType = UIReturnKeySearch;
    self.searchBar.enablesReturnKeyAutomatically = YES;
    self.searchBar.delegate = self;
    self.searchBar.barTintColor = HEX_COLOR(@"818C9E");
    if(self.isAt){
        [self.searchBar setPlaceholder:@"输入你想@的人"];
    }else{
        [self.searchBar setPlaceholder:@"搜索你想邀请的人"];
    }
    [self.searchBar setBackgroundColor:WHITE_COLOR];
    [self.searchBar setBackgroundImage:kImageWithColor(WHITE_COLOR, self.searchBar.bounds)];
    [self.searchBar setSearchFieldBackgroundImage:[kImageWithName(@"searchBackground") imageWithColor:HEX_COLOR(@"EFEFF4")] forState:UIControlStateNormal];
    [self.searchBar setSearchFieldBackgroundImage:[kImageWithName(@"searchBackground") imageWithColor:HEX_COLOR(@"EFEFF4")] forState:UIControlStateDisabled];
    [self.searchBar setSearchTextPositionAdjustment:UIOffsetMake(5, 0)];
    [self.view addSubview:self.searchBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 网络请求列表
- (void)loadViewpointHttpData{
    _noNetWork = NO;
    __weak typeof(self) weakSelf = self;
    NSString *api;
    if(self.isAt){
        api = API_NAME_POST_ATWHOIN_SUBJECT;
    }else{
        api = API_NAME_POST_RECOMD_INVITE;
    }
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@",self.tdModel.subjectid, [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:api paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if(weakSelf.listArray==nil){
            weakSelf.listArray = [NSMutableArray array];
        }
        if(weakSelf.tableArray==nil){
            weakSelf.tableArray = [NSMutableArray array];
        }
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:responseObject[@"data"]];
            for(NSDictionary *dict in array){
                ContactsModel *model = [[ContactsModel alloc] initWithDict:dict];
                [weakSelf.listArray addObject:model];
            }
            weakSelf.tableArray = [weakSelf.listArray mutableCopy];
            [weakSelf.tableView reloadData];
        }else{
            [weakSelf.tableView endRefresh];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        if(weakSelf.listArray==nil){
            weakSelf.listArray = [NSMutableArray array];
        }
        if(weakSelf.tableArray==nil){
            weakSelf.tableArray = [NSMutableArray array];
        }
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - 网络请求数据
- (void)searchResultDataHttp{
    _noNetWork = NO;
    if(self.searchArray==nil){
        self.searchArray = [NSMutableArray array];
    }
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@/%@/%ld/%@", self.tdModel.subjectid, [DataModelInstance shareInstance].userModel.userId, self.searchBar.text,(long)_currentPage,(self.isAt?@(0):@(1))] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_POST_INVITE_SEARCH paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if(_currentPage==1){
            [weakSelf.searchArray removeAllObjects];
        }
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:responseObject[@"data"]];
            for(NSDictionary *dict in array){
                ContactsModel *model = [[ContactsModel alloc] initWithDict:dict];
                [weakSelf.searchArray addObject:model];
            }
            [weakSelf.tableView tableViewAddUpLoadRefreshing:^{
                if(weakSelf.searchBar.text.length){
                    [weakSelf searchResultDataHttp];
                }
            }];
            if(array.count){
                _currentPage++;
                [weakSelf.tableView.mj_footer endRefreshing];
            }else{
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }else{
            [weakSelf.tableView.mj_footer endRefreshing];
        }
        if(weakSelf.searchBar.text.length == 0){
            [weakSelf.searchArray removeAllObjects];
            weakSelf.tableArray = [weakSelf.listArray mutableCopy];
        }else{
            weakSelf.tableArray = [weakSelf.searchArray mutableCopy];
        }
        [weakSelf.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        _noNetWork = YES;
        [weakSelf.searchArray removeAllObjects];
        if(weakSelf.searchBar.text.length == 0){
            weakSelf.tableArray = [weakSelf.listArray mutableCopy];
        }else{
            weakSelf.tableArray = [weakSelf.searchArray mutableCopy];
        }
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark -- UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.tableArray==nil){
        return 0;
    }else if(!self.tableArray.count&&_noNetWork){
        return 1;
    }else{
        return self.tableArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(!self.tableArray.count&&_noNetWork){
        return self.tableView.frame.size.height;
    }else{
        return 85;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(!self.tableArray.count&&_noNetWork){
        static NSString *identify = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"NONetWorkTableViewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }else{
        static NSString *identify = @"SearchFriendTableViewCell";
        SearchFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"SearchFriendTableViewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell updateDisplay:self.tableArray[indexPath.row] tdModel:self.tdModel searchText:self.searchBar.text hideAddBtn:self.isAt];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.searchBar resignFirstResponder];
    if(self.tableArray.count){
        ContactsModel *model = self.tableArray[indexPath.row];
        if(self.isAt){
            NSInteger sum = self.navigationController.viewControllers.count;
            ZSSRichTextEditor *vc = self.navigationController.viewControllers[sum-2];
            vc.atPerson(model);
            vc.type = EditotType_Viewpoint;
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            NewMyHomePageController *myhome = [[NewMyHomePageController alloc]init];
            myhome.userId = model.userid;
            [self.navigationController pushViewController:myhome animated:YES];
        }
    }
}

#pragma mark -- SearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if(searchText.length){
        [self.tableArray removeAllObjects];
        if(_currentPage==1){
            [self.tableView reloadData];
        }
        _currentPage = 1;
        [self searchResultDataHttp];
    }else{
        _currentPage = 1;
        if(self.tableView.mj_footer!=nil){
            [self.tableView.mj_footer removeFromSuperview];
            self.tableView.mj_footer = nil;
        }
        [self.tableArray removeAllObjects];
        [self.tableView reloadData];
        self.tableArray = [self.listArray mutableCopy];
        [self.tableView reloadData];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}


@end
