//
//  ActivityViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/29.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ActivityViewController.h"
#import "DelectDataView.h"
#import "NONetWorkTableViewCell.h"
#import "ActivityVIewCell.h"
#import "ActivityDetailController.h"
#import "CreateActivityViewController.h"
#import "TopicIdentifyViewController.h"
#import "TagSearchView.h"
#import "SearchAvtivityAndFianaceController.h"

#import "ReportView.h"
#import "ReportViewCell.h"
#import "ReportTitleLabel.h"
#import "ReportPushTitleCell.h"
#import "InformationDetailController.h"
#import "ActivityOverViewCell.h"
//下拉
#import "DOPDropDownMenu.h"
#import "notChoseView.h"
#import "RcomActivityView.h"

@interface ActivityViewController ()<DOPDropDownMenuDataSource,DOPDropDownMenuDelegate,notChoseViewDelegate>
@property (nonatomic,strong) UIButton *showBtnNotWork;
@property (nonatomic,assign)  BOOL netWorkStat;
@property (nonatomic,assign)   NSInteger currentPag;
@property (nonatomic,strong)  NSMutableArray *dataArray;
@property (nonatomic,strong) MyActivityModel *activityModle;
@property (nonatomic,strong) SubjectlistModel *subjectlistModel;
@property (nonatomic,strong) ReportModel *reportModel;
//专题活动
@property (nonatomic,strong) ReportView *reportView;
//报道数组
@property (nonatomic,strong)  NSMutableArray *subjectlistArray;
//活动推荐数组
@property (nonatomic,strong)  NSMutableArray *recommendactivityArray;
//活动报道
@property (nonatomic,strong)  NSMutableArray *reportArray;
@property (nonatomic ,strong)DelectDataView *delectView;
@property (nonatomic ,strong) UIButton *btn;
@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic, strong) DOPDropDownMenu *menu;
//cityname
@property (nonatomic ,strong) NSString *cityname;
@property (nonatomic ,strong) NSString *orderby;
@property (nonatomic ,strong) NSString *feerMoney;
@property (nonatomic ,strong) NSString *tagid;
@property (nonatomic ,strong) NSString *time;
@property (nonatomic ,assign)  BOOL isCapacity;
@property (nonatomic ,strong) NSMutableArray *choseArray;
@property (nonatomic ,strong) notChoseView *choseView;
@property (nonatomic ,strong) RcomActivityView *rcomView;
//当前筛选框是否需要滚动
@property (nonatomic ,assign)  BOOL isScroview;
//推荐数据
@property (nonatomic ,strong)NSMutableArray *rcmdArray;
//记录高度
@property (nonatomic ,assign) CGFloat menViewHeigth;
//浮沉
@property (nonatomic ,strong) UIView *coverView;

@property (nonatomic,assign)  BOOL isForw;
@property (nonatomic ,assign) BOOL isSelectTop;

@end
@implementation ActivityViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //  筛选活动
    if (self.choseArray.count == 0) {
        [self createrChoseData];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netWorkChange:) name:kReachabilityChangedNotification object:nil];
    //Sectyion滚动到最顶
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tapAction) name:@"menuButtons" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(referData:) name:ACTIVITYDOWNMENU object:nil];
    if(self.showBackBtn){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        self.tabBarController.tabBar.hidden = YES;
        self.navigationController.navigationBarHidden = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(self.showBackBtn){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isCapacity = YES;
    if(self.showBackBtn){
        [self updateVCDisplay];
    }
    __weak typeof(self) weakSelf = self;
    self.leftButtonClicked = ^(){
        if (weakSelf.isForw) {
            [weakSelf packUpAction];
        }
    };
    
    self.coverView = [[UIView alloc]initWithFrame:CGRectMake(0, HEIGHT - 49, WIDTH, 49)];
    self.coverView.backgroundColor = CoverViewColor;
    UITapGestureRecognizer *packUpTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(packUpAction)];
    [self.coverView addGestureRecognizer:packUpTap];
    
    [[AppDelegate shareInstance] setZhugeTrack:@"进入活动" properties:@{}];
}
#pragma mark ------  创建下拉筛选
- (void)createrDropDownMenuView{
    NSArray *array  = @[@"即将开始",@"最热活动"];
    _titles = [NSMutableArray arrayWithArray:array];
    _menu = [[DOPDropDownMenu alloc] initWithOrigin:CGPointMake(0, 10) andHeight:44 coverHeigth:self.menViewHeigth];
    _menu.delegate = self;
    _menu.dataSource = self;
}
#pragma mark ------- 滚动到顶
- (void)tapAction{
    self.isForw = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:self.coverView];
    self.tableView.scrollEnabled = NO;
    if (self.isScroview) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma maek ----- 下拉收回，允许滚动
- (void)referData:(NSNotification *)object{
    self.isForw = NO;
    [self.coverView removeFromSuperview];
    self.tableView.scrollEnabled = YES;
}

#pragma maek ----- 收起视频
- (void)packUpAction{
    [self.menu backgroundPackUpMenu];
}

#pragma mark ------ 预加载
- (void)updateVCDisplay{
    self.isCapacity = YES;
    self.dataArray = [NSMutableArray new];
    self.subjectlistArray = [NSMutableArray new];
    self.recommendactivityArray =  [NSMutableArray new];
    self.reportArray = [NSMutableArray new];
    self.choseArray = [NSMutableArray new];
    self.rcmdArray = [NSMutableArray new];
    //活动Tag
    NSArray *subjectlistArray = [CommonMethod paramArrayIsNull:[ [DataModelInstance shareInstance].userModel.pushActivityDic objectForKey:@"subjectlist"]];
    for (NSDictionary *subjectlistDic in subjectlistArray) {
        self.subjectlistModel = [[SubjectlistModel alloc] initWithDict:subjectlistDic];
        [self.subjectlistArray addObject:self.subjectlistModel];
    }
    
    //推荐活动
    NSArray *recommendactivityArray = [CommonMethod paramArrayIsNull:[[DataModelInstance shareInstance].userModel.pushActivityDic objectForKey:@"recommendactivity"]];
    for (NSDictionary *recommendactivityDic in recommendactivityArray) {
        self.activityModle = [[MyActivityModel alloc] initWithDict:recommendactivityDic];
        [self.recommendactivityArray addObject:self.activityModle];
    }
    MyActivityModel *activityModel = [[MyActivityModel alloc] init];
    activityModel.name = @"金融时报-P2P理财的坑";
    activityModel.image = @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1535636692071&di=65a7bc4c9f509a2da65dea7e48c1049d&imgtype=jpg&src=http%3A%2F%2Fimg0.imgtn.bdimg.com%2Fit%2Fu%3D28193685%2C605063109%26fm%3D214%26gp%3D0.jpg";
    activityModel.timestr = @"2018-03-09";
    activityModel.cityname = @"上海";
    activityModel.districtname = @"虹口区";
    [self.recommendactivityArray addObject:activityModel];
    //推荐报道
    NSArray *reportArray = [CommonMethod paramArrayIsNull:[[DataModelInstance shareInstance].userModel.pushActivityDic objectForKey:@"report"]];
    for (NSDictionary *reportDic in reportArray) {
        self.reportModel = [[ReportModel alloc] initWithDict:reportDic];
        [self.reportArray addObject:self.reportModel];
    }
    //活动筛选
    UserModel *userModel = [DataModelInstance shareInstance].userModel;
    if(userModel.activityData.count){
        for (NSDictionary *dict in userModel.activityData) {
            self.activityModle = [[MyActivityModel alloc] initWithDict:dict];
            [self.dataArray addObject:self.activityModle];
        }
    }
    //活动推荐
    if(userModel.recomArray.count){
        for (NSDictionary *dict in userModel.recomArray) {
            self.activityModle = [[MyActivityModel alloc] initWithDict:dict];
            [self.rcmdArray addObject:self.activityModle];
        }
    }
    
    //  筛选活动
    if (self.choseArray.count == 0) {
        [self createrChoseData];
    }
    if(self.showBackBtn){
        [self createCustomNavigationBar:@"活动"];
        [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    }else{
        [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64-49)];
    }
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.netWorkStat = NO;
    self.currentPag = 1;
    self.isSelectTop = NO;
    [self getActivityPushAbout];
    [self getMyActivityList:self.currentPag intelligentIndexStat:self.isCapacity cityname:self.cityname tagid:self.tagid orderby:self.orderby time:self.time freeMoney:self.feerMoney];
    [self createrTabViewHeaderView];
    [self.tableView tableViewAddDownLoadRefreshing:^{
        [self getActivityPushAbout];
        self.currentPag = 1;
        self.isCapacity = YES;
        self.cityname = @"";
        self.tagid = @"";
        self.orderby = @"";
        self.time = @"";
        self.feerMoney = @"";
        self.isSelectTop = NO;
        [self getMyActivityList:self.currentPag intelligentIndexStat:self.isCapacity cityname:self.cityname tagid:self.tagid orderby:self.orderby time:self.time freeMoney:self.feerMoney];
    }];
    [self.tableView tableViewAddUpLoadRefreshing:^{
        self.isSelectTop = NO;
        self.currentPag ++;
        [self getMyActivityList:self.currentPag intelligentIndexStat:self.isCapacity cityname:self.cityname tagid:self.tagid orderby:self.orderby time:self.time freeMoney:self.feerMoney];
    }];
    [self createNavBarButtonItemsActivity];
}
#pragma mark----- 初始化筛选数据
- (void)createrChoseData{
    //智能筛选
    for (NSDictionary *dic  in [DataModelInstance shareInstance].userModel.capacityArray) {
        NSString *name = dic[@"name"];
        NSMutableArray *titleArray  = [NSMutableArray new];
        NSArray *dicArray = dic[@"childtag"];
        
        for (NSDictionary *subDic in dicArray) {
            ReportModel *model = [[ReportModel alloc]init];
            model.postid = subDic[@"id"];
            model.title = subDic[@"name"];
            [titleArray addObject:model];
        }
        NSDictionary *dic = @{name:titleArray};
        [self.choseArray addObject:dic];
    }
    
}
//导航栏右边按钮
- (void)createNavBarButtonItemsActivity{
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(0, 0, 30, 40);
    [searchBtn setImage:kImageWithName(@"btn_search_white") forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(gotoSearchButtonClickedActivity:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    
    UIButton *publishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    publishBtn.frame = CGRectMake(0, 0, 30, 40);
    [publishBtn setImage:kImageWithName(@"posticon_topic_post") forState:UIControlStateNormal];
    [publishBtn addTarget:self action:@selector(gotoPublishButtonClickedActivity:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *publishButtonItem = [[UIBarButtonItem alloc] initWithCustomView:publishBtn];
    
    self.navigationItem.rightBarButtonItems =@[publishButtonItem, searchButtonItem];
}
#pragma mark ------ 活动搜索
- (void)gotoSearchButtonClickedActivity:(UIButton *)btn{
    if (self.isForw) {
        [self packUpAction];
        
    }
    SearchAvtivityAndFianaceController *vc = [CommonMethod getVCFromNib:[SearchAvtivityAndFianaceController class]];
    vc.type = SearchResult_Activity;
    vc.isHideNavBack = YES;
    vc.view.transform = CGAffineTransformMakeTranslation(0, 64);
    vc.view.alpha = 0.8;
    [UIView animateWithDuration:0.3 animations:^{
        vc.view.alpha = 1;
        vc.view.transform = CGAffineTransformMakeTranslation(0, 0);
    }];
    [self.navigationController pushViewController:vc animated:NO];
}
#pragma mark ----- 发表活动
-(void)gotoPublishButtonClickedActivity:(UIButton *)btn{
    if (self.isForw) {
        [self packUpAction];
        
    }
    if([DataModelInstance shareInstance].userModel.hasValidUser.integerValue == 1){
        CreateActivityViewController *vc = [CommonMethod getVCFromNib:[CreateActivityViewController class]];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        TopicIdentifyViewController *vc = [CommonMethod getVCFromNib:[TopicIdentifyViewController class]];
        vc.publishType = PublishType_Activity;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
#pragma mark------- 获取活动
- (void)getActivityPushAbout{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@", [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_ACTIVITY_REPORT paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if (weakSelf.reportArray) {
            [weakSelf.recommendactivityArray removeAllObjects];
            [weakSelf.subjectlistArray removeAllObjects];
            [weakSelf.reportArray  removeAllObjects];
        }
        [hud hideAnimated:YES];
        weakSelf.netWorkStat = NO;
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSDictionary *dict = [CommonMethod paramDictIsNull:[responseObject objectForKey:@"data"]];
            UserModel *model = [DataModelInstance shareInstance].userModel;
            model.pushActivityDic = [CommonMethod paramDictIsNull:dict];
            [DataModelInstance shareInstance].userModel = model;
            NSArray *subjectlistArray = [CommonMethod paramArrayIsNull:[dict objectForKey:@"subjectlist"]];
            for (NSDictionary *subjectlistDic in subjectlistArray) {
                weakSelf.subjectlistModel = [[SubjectlistModel alloc] initWithDict:subjectlistDic];
                [weakSelf.subjectlistArray addObject:weakSelf.subjectlistModel];
            }
            NSArray *recommendactivityArray = [CommonMethod paramArrayIsNull:[dict objectForKey:@"recommendactivity"]];
            for (NSDictionary *recommendactivityDic in recommendactivityArray) {
                weakSelf.activityModle = [[MyActivityModel alloc] initWithDict:recommendactivityDic];
                [weakSelf.recommendactivityArray addObject:weakSelf.activityModle];
            }
            MyActivityModel *activityModel = [[MyActivityModel alloc] init];
            activityModel.name = @"金融时报-P2P理财的坑";
            activityModel.image = @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1535636692071&di=65a7bc4c9f509a2da65dea7e48c1049d&imgtype=jpg&src=http%3A%2F%2Fimg0.imgtn.bdimg.com%2Fit%2Fu%3D28193685%2C605063109%26fm%3D214%26gp%3D0.jpg";
            activityModel.timestr = @"2018-03-09";
            activityModel.cityname = @"上海";
            activityModel.districtname = @"虹口区";
            [weakSelf.recommendactivityArray addObject:activityModel];
            [weakSelf.recommendactivityArray addObject:activityModel];
            [weakSelf.recommendactivityArray addObject:activityModel];
            
            NSArray *reportArray = [CommonMethod paramArrayIsNull:[dict objectForKey:@"report"]];
            
            for (NSDictionary *reportDic in reportArray) {
                weakSelf.reportModel = [[ReportModel alloc] initWithDict:reportDic];
                [weakSelf.reportArray addObject:weakSelf.reportModel];
            }
            if (weakSelf.subjectlistArray.count > 0) {
                [self createrTabViewHeaderView];
            }
            [weakSelf.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        weakSelf.netWorkStat = YES;
        [weakSelf.tableView reloadData];
    }];
}
#pragma mark------- 表示图
- (void)createrTabViewHeaderView{
    self.menViewHeigth = 0;
    self.reportView = [[ReportView alloc]init];
    if (self.subjectlistArray.count > 4) {
        self.reportView.frame = CGRectMake(0,0, WIDTH, 222);
        self.menViewHeigth = 220;
    }else{
        self.menViewHeigth = 110;
        self.reportView.frame = CGRectMake(0,0, WIDTH, 120);
    }
    self.menViewHeigth += 384;
    for (NSInteger i = 0; i < self.reportArray.count; i++) {
        self.reportModel = self.reportArray[i];
        self.menViewHeigth += self.reportModel.cellHeight;
    }
    [self createrDropDownMenuView];
    [self.reportView createrReport:self.subjectlistArray isAllShow:NO];
    self.tableView.tableHeaderView = self.reportView;
}
/*
 page  ----- 页数
 intelligent  --- 是否智能推荐（1是 0否 如果是智能推荐则别的搜索条件无效只显示智能推荐的结果）
 cityname    -------  城市搜索
 tagid ------ 行业标签id 多个则,分割如 22,44
 orderby -- 排序 new即将开始 hot最热活动
 time   ----- 时间筛选 1 周末， 2最近1周， 3最近一个月， 4最近3个月
 freeMoney ----- 是否付费 yes付费 no免费
 */
#pragma mark ------  获取活动列表
- (void)getMyActivityList:(NSInteger)page intelligentIndexStat:(BOOL)type cityname:(NSString *)cityname tagid:(NSString *)tagid orderby:(NSString *)orderby time:(NSString *)timeindex  freeMoney:(NSString *)freeMoney{
    __weak typeof(self) weakSelf = self;
    self.tableView.tableFooterView = [UIView new];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"%ld", page] forKey:@"page"];
    [requestDict setObject:[NSString stringWithFormat:@"%@",[DataModelInstance shareInstance].userModel.userId] forKey:@"userid"];
    if (cityname.length > 0) {
        [requestDict setObject:[NSString stringWithFormat:@"%@",cityname] forKey:@"cityname"];
    }
    if (orderby.length > 0) {
        [requestDict setObject:[NSString stringWithFormat:@"%@",orderby] forKey:@"orderby"];
    }
    if (tagid.length > 0) {
        [requestDict setObject:[NSString stringWithFormat:@"%@",tagid] forKey:@"tagid"];
        [requestDict setObject:@"0" forKey:@"intelligent"];
    }else{
        [requestDict setObject:@"1" forKey:@"intelligent"];
    }
    if (freeMoney.length > 0) {
        [requestDict setObject:[NSString stringWithFormat:@"%@",freeMoney] forKey:@"fee"];
    }
    if (timeindex.length > 0) {
        [requestDict setObject:[NSString stringWithFormat:@"%@",timeindex] forKey:@"time"];
    }
    
    [self requstType:RequestType_Post apiName:API_NAME_GET_ACTIVITY_ACTIVITYLIST paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        weakSelf.netWorkStat = NO;
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if (weakSelf.currentPag == 1) {
                [weakSelf.tableView endRefresh];
                [weakSelf.tableView.mj_footer resetNoMoreData];
                [weakSelf.dataArray removeAllObjects];
                [weakSelf.rcmdArray removeAllObjects];
            }
            NSDictionary *dict = [CommonMethod paramDictIsNull:[responseObject objectForKey:@"data"]];
            NSArray *searchArray = [CommonMethod paramArrayIsNull:[dict objectForKey:@"search"]];
            NSArray *rcmdArray = [CommonMethod paramArrayIsNull:[dict objectForKey:@"rcmd"]];
            if(searchArray.count ||rcmdArray.count ){
                [weakSelf.tableView endRefresh];
            }else{
                [weakSelf.tableView endRefreshNoData];
            }
            UserModel *model = [DataModelInstance shareInstance].userModel;
            model.activityData = [CommonMethod paramArrayIsNull:searchArray];
            model.activityData = [CommonMethod paramArrayIsNull:rcmdArray];
            [DataModelInstance shareInstance].userModel = model;
            for (NSDictionary *dict in searchArray) {
                weakSelf.activityModle = [[MyActivityModel alloc] initWithDict:dict];
                [weakSelf.dataArray addObject:weakSelf.activityModle];
            }
            for (NSDictionary *dict in rcmdArray) {
                weakSelf.activityModle = [[MyActivityModel alloc] initWithDict:dict];
                [weakSelf.rcmdArray addObject:weakSelf.activityModle];
            }
            [weakSelf.tableView reloadData];
        }else{
            [weakSelf.tableView endRefresh];
        }if (self.isSelectTop) {
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        weakSelf.netWorkStat = YES;
        [weakSelf.tableView endRefresh];
        [weakSelf.tableView reloadData];
    }];
}
#pragma mark - 网络变化
- (void)netWorkChange:(NSNotification *)netWorkChange{
    Reachability *reach = [netWorkChange object];
    [self showNetWorkStatue:reach.currentReachabilityStatus!=NotReachable];
}
- (void)showNetWorkStatue:(BOOL)hasNet{
    if (!hasNet) {
        if (self.showBtnNotWork==nil) {
            self.showBtnNotWork = [UIButton buttonWithType:UIButtonTypeCustom];
            self.showBtnNotWork.frame = CGRectMake(0, 0, WIDTH, 36);
            [self.tableView addSubview:self.showBtnNotWork];
            [self.showBtnNotWork setTitle:@"网络请求失败，请检查网络设置" forState:UIControlStateNormal];
            [self.showBtnNotWork setTitleColor:[UIColor colorWithHexString:@"8B4542"] forState:UIControlStateNormal];
            self.showBtnNotWork.titleLabel.font = [UIFont systemFontOfSize:14];
            self.showBtnNotWork.backgroundColor = [UIColor colorWithHexString:@"FFE1E1"];
        }
    }else{
        if(self.dataArray.count==0){
            self.isSelectTop = NO;
            [self getMyActivityList:self.currentPag intelligentIndexStat:self.isCapacity cityname:self.cityname tagid:self.tagid orderby:self.orderby time:self.time freeMoney:self.feerMoney];
        }
        if(self.showBtnNotWork){
            [self.showBtnNotWork removeFromSuperview];
            self.showBtnNotWork = nil;
        }
    }
    // Do any additional setup after loading the view from its nib.
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableViewDelegate/DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.netWorkStat == YES && self.dataArray.count == 0){
        return 1;
    }else if (section == 0) {
        return 2;
    }else if (section == 1) {
        return self.reportArray.count + 2;
    }else  {
        NSInteger searchIndex = self.dataArray.count;
        NSInteger rcmIndex = self.rcmdArray.count;
        if (searchIndex >= 5) {
            return searchIndex;
        }else if(searchIndex < 5 && searchIndex > 0){
            return searchIndex+rcmIndex+1;
        }else{
            return rcmIndex+2;
        }
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 2) {
        return 44;
    }
    return 0;
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    __weak typeof(self) weakSelf = self;
    //当下拉菜单收回时的回调，用于网络请求新的数据
    _menu.finishedChangeBlock = ^(NSInteger col, NSInteger pow) {
        if (col == 0) {
            weakSelf.time = @"1";
        }else if (col == 1) {
            weakSelf.time = @"2";
        }else if (col == 2) {
            weakSelf.time = @"3";
        }else if (col == 3) {
            weakSelf.time = @"4";
        }else if (col == -1) {
            weakSelf.time = @"";
        }
        if (pow == 0) {
            weakSelf.feerMoney = @"no";
        }else if (pow == 1) {
            weakSelf.feerMoney = @"yes";
        }else if (pow == -1) {
            weakSelf.feerMoney = @"";
        }
        weakSelf.currentPag = 1;
        weakSelf.isCapacity = YES;
        weakSelf.isSelectTop = YES;
        [weakSelf getMyActivityList:weakSelf.currentPag intelligentIndexStat:weakSelf.isCapacity cityname:weakSelf.cityname tagid:weakSelf.tagid orderby:weakSelf.orderby time:weakSelf.time freeMoney:weakSelf.feerMoney];
    };
    _menu.finishedBlock=^(DOPIndexPath *indexPath){
        if (indexPath.column == 0) {
            if (indexPath.item < 0) {
                weakSelf.currentPag = 1;
                weakSelf.isCapacity = YES;
                weakSelf.isSelectTop = YES;
                weakSelf.tagid = @"";
                [weakSelf getMyActivityList:weakSelf.currentPag intelligentIndexStat:weakSelf.isCapacity cityname:weakSelf.cityname tagid:weakSelf.tagid orderby:weakSelf.orderby time:weakSelf.time freeMoney:weakSelf.feerMoney];
                return ;
            }
        }
        if (indexPath.item >= 0) {
            NSDictionary *dic = weakSelf.choseArray[indexPath.row - 1];
            NSArray *array = dic[dic.allKeys[0]];
            if (indexPath.item == 0) {
                NSMutableArray *titleArray = [NSMutableArray new];
                for (NSInteger i = 0; i < array.count; i++) {
                    ReportModel *model = array[i];
                    [titleArray addObject:model.postid];
                }
                weakSelf.tagid = [titleArray componentsJoinedByString:@","];
            }else{
                ReportModel *model = array[indexPath.item - 1];
                weakSelf.tagid = [NSString stringWithFormat:@"%@",model.postid];
            }
            weakSelf.currentPag = 1;
            weakSelf.isCapacity = NO;
            weakSelf.isSelectTop = YES;
            [weakSelf getMyActivityList:weakSelf.currentPag intelligentIndexStat:weakSelf.isCapacity cityname:weakSelf.cityname tagid:weakSelf.tagid orderby:weakSelf.orderby time:weakSelf.time freeMoney:weakSelf.feerMoney];
        }else {
            if (indexPath.column == 1) {
                weakSelf.cityname = [DataModelInstance shareInstance].userModel.cityName[indexPath.row];
            }
            if (indexPath.column == 2) {
                if (indexPath.row == 0) {
                    weakSelf.orderby = @"new";
                }else{
                    weakSelf.orderby = @"hot";
                }
            }
            weakSelf.isSelectTop = YES;
            weakSelf.currentPag = 1;
            weakSelf.isCapacity = NO;
            [weakSelf getMyActivityList:weakSelf.currentPag intelligentIndexStat:weakSelf.isCapacity cityname:weakSelf.cityname tagid:weakSelf.tagid orderby:weakSelf.orderby time:weakSelf.time freeMoney:weakSelf.feerMoney];
        }
        
    };
    return _menu;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES && self.dataArray.count == 0){
        return self.tableView.frame.size.height;
    }else if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 60;
        }
        return 220;
    }else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            return 60;
        }else if(indexPath.row == self.reportArray.count + 1){
            return 10;
        }else{
            self.reportModel = self.reportArray[indexPath.row - 1];
            return  self.reportModel.cellHeight;
        }
    }else{
        NSInteger searchIndex = self.dataArray.count;
        if (searchIndex >= 5) {
            self.activityModle = self.dataArray[indexPath.row];
            if ([self.activityModle.price isEqualToString:@"已结束"]) {
                return 116;
            }
            return self.activityModle.cellHeight;
        }else if(searchIndex < 5 && searchIndex > 0){
            if (indexPath.row < searchIndex ) {
                self.activityModle = self.dataArray[indexPath.row];
                if ([self.activityModle.price isEqualToString:@"已结束"]) {
                    return 116;
                }
                return self.activityModle.cellHeight;
            } else if (indexPath.row == searchIndex) {
                return 46;
            }else{
                self.activityModle = self.rcmdArray[indexPath.row - 1 - searchIndex];
                if ([self.activityModle.price isEqualToString:@"已结束"]) {
                    return 116;
                }
                return self.activityModle.cellHeight;
            }
        }else{
            if (indexPath.row == 0) {
                return 83;
            }else if (indexPath.row == 1){
                return 46;
            }else{
                self.activityModle = self.rcmdArray[indexPath.row - 2];
                if ([self.activityModle.price isEqualToString:@"已结束"]) {
                    return 116;
                }
                return self.activityModle.cellHeight;
            }
        }
    }
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES && self.dataArray.count == 0){
        static NSString *cellID = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([NONetWorkTableViewCell class])];
        }
        return cell;
    }else if (indexPath.section == 0){
        static NSString *str = @"kfal";
        if (indexPath.row == 0) {
            ReportPushTitleCell *cell = [CommonMethod getViewFromNib:NSStringFromClass([ReportPushTitleCell class])];
            cell.isShow = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell tranferNsinter];
            return cell;
        }else{
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:str];
            }
            for (UIView *vew in cell.contentView.subviews) {
                [vew removeFromSuperview];
            }
            UIScrollView *scrrolView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 244)];
            for (NSInteger i = 0; i < self
                 .recommendactivityArray.count; i++) {
                self.activityModle = self.recommendactivityArray[i];
                UIView *view = [self createrSlidView:self.activityModle xwideth:i];
                [scrrolView addSubview:view];
                view.tag = i;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hisMainPage:)];
                view.userInteractionEnabled = YES;
                [view addGestureRecognizer:tap];
            }
            CGFloat wideth = self.recommendactivityArray.count * (16+240)+16;
            scrrolView.showsHorizontalScrollIndicator = NO;
            scrrolView.contentSize = CGSizeMake(wideth, 2);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView addSubview:scrrolView];
            return cell;
        }
    }else if(indexPath.section == 1){
        if (indexPath.row == 0) {
            ReportPushTitleCell *cell = [CommonMethod getViewFromNib:NSStringFromClass([ReportPushTitleCell class])];
            cell.isShow = NO;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell tranferNsinter];
            return cell;
        }else if(indexPath.row == self.reportArray.count + 1){
            NSString *str = @"";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:str];
            }
            for(UIView *vew in cell.contentView.subviews) {
                [vew removeFromSuperview];
            }
            UIView *view = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, 10) backColor:@"EFEFF4"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView addSubview:view];
            return cell;
        }else{
            self.reportModel = self.reportArray[indexPath.row -1];
            static NSString *cellID = @"ActivityVIewCell";
            if (self.reportModel.image.length > 0) {
                ReportViewCell*cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                if (!cell) {
                    cell = [CommonMethod getViewFromNib:NSStringFromClass([ReportViewCell class])];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell tranferReportModel:self.reportModel];
                return cell;
            }else{
                ReportTitleLabel *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                if (!cell) {
                    cell = [CommonMethod getViewFromNib:NSStringFromClass([ReportTitleLabel class])];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell tranferReportModel:self.reportModel];
                return cell;
            }
        }
    }else{
        NSInteger searchIndex = self.dataArray.count;
        if (searchIndex >= 5) {
            UITableViewCell *cell = [self ActivitySearchRcom:self.tableView atIndexPath:indexPath index:0 isRcm:NO];
            return cell;
            
        }else if(searchIndex < 5 && searchIndex > 0){
            if (indexPath.row < searchIndex ) {
                UITableViewCell *cell = [self ActivitySearchRcom:self.tableView atIndexPath:indexPath index:0 isRcm:NO];
                return cell;
                
            } else if (indexPath.row == searchIndex) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@""];
                if (!cell) {
                    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@""];
                }
                for (UIView *vew in cell.contentView.subviews) {
                    [vew removeFromSuperview];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                self.rcomView = [CommonMethod getViewFromNib:NSStringFromClass([RcomActivityView class])];
                self.rcomView.frame = CGRectMake(0, 0, WIDTH, 46);
                [cell.contentView addSubview:self.rcomView];
                return cell;
            }else{
                UITableViewCell *cell = [self ActivitySearchRcom:self.tableView atIndexPath:indexPath index:1 isRcm:YES];
                return cell;
            }
        }else{
            if (indexPath.row == 0) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@""];
                if (!cell) {
                    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@""];
                }
                for (UIView *vew in cell.contentView.subviews) {
                    [vew removeFromSuperview];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = [UIColor colorWithHexString:@"EFEFF4"];
                self.choseView = [CommonMethod getViewFromNib:NSStringFromClass([notChoseView class])];
                self.choseView.frame = CGRectMake(0, 0, WIDTH, 83);
                self.choseView.notChoseViewDelegate = self;
                [cell.contentView addSubview:self.choseView];
                return cell;
            }else if (indexPath.row == 1){
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@""];
                if (!cell) {
                    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@""];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                self.rcomView = [CommonMethod getViewFromNib:NSStringFromClass([RcomActivityView class])];
                self.rcomView.frame = CGRectMake(0, 0, WIDTH, 46);
                [cell.contentView addSubview:self.rcomView];
                return cell;
                
            }else{
                UITableViewCell *cell = [self ActivitySearchRcom:self.tableView atIndexPath:indexPath index:2 isRcm:YES];
                return cell;
            }
        }
        
    }
}
/*
 array ------ 数据源
 index -----  1:推荐，2：无搜索
 isRcm ----- Yes:推荐，NO，搜索
 */
//#pragma mark------活动
- (UITableViewCell *)ActivitySearchRcom:(UITableView *)tableView atIndexPath:(NSIndexPath*)indexPath index:(NSInteger)index isRcm:(BOOL)isrcm{
    static NSString *cellID = @"ActivityVIewCell";
    NSInteger searchIndex = self.dataArray.count;
    if (searchIndex >= 5) {
        self.activityModle = self.dataArray[indexPath.row];
    }else if(searchIndex < 5 && searchIndex > 0){
        if (indexPath.row < searchIndex ) {
            self.activityModle = self.dataArray[indexPath.row];
        } else if (indexPath.row == searchIndex) {
        }else{
            self.activityModle = self.rcmdArray[indexPath.row - 1 - searchIndex];
        }
    }else{
        if (indexPath.row > 1) {
            self.activityModle = self.rcmdArray[indexPath.row - 2];
        }
    }
    if ([self.activityModle.price isEqualToString:@"已结束"]) {
        ActivityOverViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([ActivityOverViewCell class])];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell tranferActivityVIewCellModel:self.activityModle];
        return cell;
    }else{
        ActivityVIewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([ActivityVIewCell class])];
        }
        cell.index = indexPath.row;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell tranferActivityVIewCellModel:self.activityModle];
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.netWorkStat == YES && self.dataArray.count == 0) {
        self.currentPag = 1;
        self.isSelectTop = NO;
        [self getMyActivityList:self.currentPag intelligentIndexStat:self.isCapacity cityname:self.cityname tagid:self.tagid orderby:self.orderby time:self.time freeMoney:self.feerMoney];
    }else if (indexPath.section == 1){
        if (indexPath.row > 0 && indexPath.row != self.reportArray.count + 1) {
            self.reportModel = self.reportArray[indexPath.row - 1];
            InformationDetailController *vc = [[InformationDetailController alloc] init];
            vc.postID = self.reportModel.pid;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else if (indexPath.section == 2){
        NSInteger searchIndex = self.dataArray.count;
        if (searchIndex >= 5) {
            self.activityModle = self.dataArray[indexPath.row];
            [self gotoActionDetailModel:self.activityModle];
        }else if(searchIndex < 5 && searchIndex > 0){
            if (indexPath.row < searchIndex ) {
                self.activityModle = self.dataArray[indexPath.row];
                [self gotoActionDetailModel:self.activityModle];
            } else if (indexPath.row == searchIndex) {
            }else{
                self.activityModle = self.rcmdArray[indexPath.row - 1 - searchIndex];
                [self gotoActionDetailModel:self.activityModle];
            }
        }else{
            if (indexPath.row > 1) {
                self.activityModle = self.rcmdArray[indexPath.row - 2];
                [self gotoActionDetailModel:self.activityModle];
            }
        }
    }
}
#pragma mark -- 进入活动详情
-(void)gotoActionDetailModel:(MyActivityModel *)model{
    ActivityDetailController *activityDetail = [[ActivityDetailController alloc]init];
    activityDetail.activityid = model.activityid;
    [self.navigationController pushViewController:activityDetail animated:YES];
}
#pragma mark ------ 进入活动推荐详情
- (void)hisMainPage:(UITapGestureRecognizer *)g{
    NSInteger index = g.view.tag;
    self.activityModle = self.recommendactivityArray[index];
    ActivityDetailController *detail = [[ActivityDetailController alloc]init];
    if(self.activityModle.activityid){
        detail.activityid = self.activityModle.activityid;
    }else{
        return;
    }
    [self.navigationController pushViewController:detail animated:YES];
}
#pragma mark ------ 创建滚动View
- (UIView *)createrSlidView:(MyActivityModel *)model xwideth:(CGFloat)xWideth{
    CGFloat x = 16;
    CGFloat y = 0;
    UIView *homeView = [NSHelper createrViewFrame:CGRectMake(x + (240+16)*xWideth, y,240, 204) backColor:@"FAFAFB"];
    UIImageView *coverImageView = [UIImageView drawImageViewLine:CGRectMake(10, 10, 220, 123) bgColor:[UIColor clearColor]];
    [coverImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KWidthImageDefault];
    [homeView addSubview:coverImageView];
    CGFloat heigth = coverImageView.frame.origin.y+coverImageView.frame.size.height + 9;
    UILabel *nameLabel = [UILabel createLabel:CGRectMake(10, heigth, 220, 15) font:[UIFont systemFontOfSize:15] bkColor:[UIColor colorWithHexString:@"FAFAFB"] textColor:[UIColor colorWithHexString:@"41464E"]];
    nameLabel.text = model.name;
    [homeView addSubview:nameLabel];
    heigth = heigth + 22;
    UILabel *companyLabel = [UILabel createLabel:CGRectMake(10, heigth, 220, 12) font:[UIFont systemFontOfSize:12] bkColor:[UIColor colorWithHexString:@"FAFAFB"] textColor:[UIColor colorWithHexString:@"818C9E"]];
    companyLabel.text = model.timestr;
    [homeView addSubview:companyLabel];
    heigth = heigth + 18;
    UILabel *positionLabel = [UILabel createLabel:CGRectMake(10, heigth, 220, 14) font:[UIFont systemFontOfSize:12] bkColor:[UIColor colorWithHexString:@"FAFAFB"] textColor:[UIColor colorWithHexString:@"818C9E"]];
    positionLabel.text = [NSString stringWithFormat:@"%@%@",model.cityname,model.districtname];
    [homeView addSubview:positionLabel];
    homeView.layer.borderWidth = 0.5;
    homeView.layer.borderColor = [[UIColor colorWithHexString:@"D9D9D9"] CGColor];
    return homeView;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y >= self.menViewHeigth) {
        self.isScroview = NO;
    }else{
        self.isScroview = YES;
    }
}
#pragma mark ---- 清空筛选条件
- (void)clearAllChoseCondition{
    self.currentPag = 1;
    self.isCapacity = YES;
    self.cityname = @"";
    self.tagid = @"";
    self.orderby = @"";
    self.time = @"";
    self.feerMoney = @"";
    [self createrDropDownMenuView];
    self.isSelectTop = NO;
    [self getMyActivityList:self.currentPag intelligentIndexStat:self.isCapacity cityname:self.cityname tagid:self.tagid orderby:self.orderby time:self.time freeMoney:self.feerMoney];
    
}
//下拉代理方法
// new datasource
- (NSString *)menu:(DOPDropDownMenu *)menu imageNameForRowAtIndexPath:(DOPIndexPath *)indexPath{
    if (indexPath.column == 0 || indexPath.column == 1) {
        return [NSString stringWithFormat:@"ic_filter_category_%ld",indexPath.row];
    }
    return nil;
}
- (NSString *)menu:(DOPDropDownMenu *)menu imageNameForItemsInRowAtIndexPath:(DOPIndexPath *)indexPath{
    if (indexPath.column == 0 && indexPath.item >= 0) {
        return [NSString stringWithFormat:@"ic_filter_category_%ld",indexPath.item];
    }
    return nil;
}
// new datasource
- (NSString *)menu:(DOPDropDownMenu *)menu detailTextForRowAtIndexPath:(DOPIndexPath *)indexPath{
    if (indexPath.column < 2) {
        return [@(arc4random()%1000) stringValue];
    }
    return nil;
}

- (NSString *)menu:(DOPDropDownMenu *)menu detailTextForItemsInRowAtIndexPath:(DOPIndexPath *)indexPath{
    return [@(arc4random()%1000) stringValue];
}

- (NSInteger)menu:(DOPDropDownMenu *)menu numberOfItemsInRow:(NSInteger)row column:(NSInteger)column{
    if (column == 0) {
        if (row == 1) {
            NSDictionary *dic = self.choseArray[0];
            NSArray *array = dic[dic.allKeys[0]];
            return array.count + 1;
        } else if (row == 2){
            NSDictionary *dic = self.choseArray[1];
            NSArray *array = dic[dic.allKeys[0]];
            return array.count + 1;
            
        } else if (row == 3){
            NSDictionary *dic = self.choseArray[2];
            NSArray *array = dic[dic.allKeys[0]];
            return array.count + 1;
        }
    }
    return 0;
}
- (NSString *)menu:(DOPDropDownMenu *)menu titleForItemsInRowAtIndexPath:(DOPIndexPath *)indexPath{
    if (indexPath.column == 0) {
        if (indexPath.row == 1) {
            if (indexPath.item == 0) {
                return @"全部互联网金融";
            }
            NSDictionary *dic = self.choseArray[0];
            NSArray *array = dic[dic.allKeys[0]];
            ReportModel *model = array[indexPath.item - 1];
            return model.title;
        } else if (indexPath.row == 2){
            if (indexPath.item == 0) {
                return @"全部传统金融";
            }
            NSDictionary *dic = self.choseArray[1];
            NSArray *array = dic[dic.allKeys[0]];
            ReportModel *model = array[indexPath.item - 1];
            return model.title;
        } else if (indexPath.row == 3){
            if (indexPath.item == 0) {
                return @"全部其他金融服务";
            }
            NSDictionary *dic = self.choseArray[2];
            NSArray *array = dic[dic.allKeys[0]];
            ReportModel *model = array[indexPath.item - 1];
            return model.title;
        }
    }
    return nil;
}
- (NSInteger)numberOfColumnsInMenu:(DOPDropDownMenu *)menu{
    return 4;
}
- (NSInteger)menu:(DOPDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column{
    if (column == 0) {
        return self.choseArray.count+1;
    }else if (column == 1){
        return   [DataModelInstance shareInstance].userModel.cityName.count;
    }else if (column == 2){
        return _titles.count;
    }else{
        return 1;
    }
}

- (NSString *)menu:(DOPDropDownMenu *)menu titleForRowAtIndexPath:(DOPIndexPath *)indexPath{
    if (indexPath.column == 0) {
        if (indexPath.row == 0) {
            return @"推荐";
        }
        NSDictionary *dic = self.choseArray[indexPath.row - 1];
        return  dic.allKeys[0];
    } else if (indexPath.column == 1){
        if ( [DataModelInstance shareInstance].userModel.cityName.count > 0) {
            return [DataModelInstance shareInstance].userModel.cityName[indexPath.row];
        }
        return @"";
    } else if (indexPath.column  == 2){
        return _titles[indexPath.row];
    }else{
        return @"筛选";
    }
}
@end
