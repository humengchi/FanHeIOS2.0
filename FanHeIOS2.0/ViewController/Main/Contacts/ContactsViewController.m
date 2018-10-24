//
//  ContactsViewController.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/15.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//
#import "ContactsViewController.h"
#import "ContactsCell.h"
#import "NONetWorkTableViewCell.h"
#import "NODataTableViewCell.h"
#import "ContactsLoadDataView.h"
#import "NewFriendsController.h"
#import "PhoneFriendsController.h"
#import "VistorsListViewController.h"
#import "SearchFriendViewController.h"
#import "DetaileViewController.h"
#import "VisitPhoneBookView.h"
#import "MyCofferViewController.h"

#import "InformationDetailController.h"
#import "ActivityDetailController.h"
#import "TopicViewController.h"
#import "CoffeeIntroduceViewController.h"
#import "PosterWebViewController.h"

#import "SearchFriendListViewController.h"
#import "EditPersonalInfoViewController.h"
#import "SearchCompanyViewController.h"
#import "CardListViewController.h"
#import "MenuView.h"
#import "ScanCameraController.h"
#import "FirstLaunchGuideView.h"
#import "GroupSetUpViewController.h"
#import "MyGroupViewController.h"

@interface ContactsViewController (){
    BOOL        _noNetWork;
    BOOL        _isLoadHttp;
    NSInteger   _currentTab;
}

@property (nonatomic, strong) NSMutableArray    *dataArray1;
@property (nonatomic, strong) NSMutableArray    *dataArray2;
@property (nonatomic, strong) NSMutableArray    *dataArray3;
@property (nonatomic, strong) NSMutableArray    *dataArray4;
@property (nonatomic, strong) UIButton          *showBtnNotWork;
@property (nonatomic, weak) IBOutlet UIView     *btnView;
@property (nonatomic, strong) UIView            *btnsView;
@property (nonatomic, weak) IBOutlet UILabel    *friendApplyNumLabel;
@property (nonatomic, weak) IBOutlet UILabel    *coffeeNumLabel;

@property (nonatomic, strong) BannerModel       *bannerModel;
@property (nonatomic, strong) NSMutableArray    *tagsArray;

@property (nonatomic, strong) MenuView *menuView;
@property (nonatomic, assign) BOOL menuShow;

@end

@implementation ContactsViewController

// 作用：拦截手势触发
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if(self.menuShow){
        self.menuShow = NO;
        [self.menuView showMenuWithAnimation:self.menuShow];
        self.menuView = nil;
    }
    if (self.navigationController.childViewControllers.count == 1){
        return NO;
    }
    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
        CGPoint translatedPoint = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self.view];
        if(translatedPoint.x < 0 || translatedPoint.y){
            return NO;
        }
        if([gestureRecognizer locationInView:self.view].x>50){
            return NO;
        }
    }
    return YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:FirstLaunchGuideViewMarkContact] && [AppDelegate shareInstance].tabBarController.selectedIndex==1){
        FirstLaunchGuideView *view = [CommonMethod getViewFromNib:@"FirstLaunchGuideView"];
        view.viewType = FLGV_Type_Contact;
        [view newUserGuide];
        view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[AppDelegate shareInstance] setZhugeTrack:@"进入人脉" properties:@{}];
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(0, 0, 30, 40);
    [addBtn setImage:kImageWithName(@"btn_fb_add") forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addBtnItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    self.navigationItem.rightBarButtonItem = addBtnItem;
    
    __weak typeof(self) weakSelf = self;
    self.leftButtonClicked = ^(){
        if(weakSelf.menuShow){
            weakSelf.menuShow = NO;
            [weakSelf.menuView showMenuWithAnimation:weakSelf.menuShow];
            weakSelf.menuView = nil;
        }
    };
}

#pragma mark ------- 加号按钮
- (void)addButtonClicked:(UIButton*)sender{
    _menuShow = !_menuShow;
    [self.menuView showMenuWithAnimation:_menuShow];
    if(_menuShow==NO){
        self.menuView = nil;
    }
}

//弹出下拉菜单
- (MenuView *)menuView{
    if (!_menuView) {
        NSArray *dataArray = @[@{@"itemName" : @"识别名片", @"imageName":@"icon_add_smmp"},@{@"itemName" : @"扫一扫", @"imageName":@"icon_scan_as"},@{@"itemName" : @"发起群聊", @"imageName":@"icon_add_cjql"},@{@"itemName" : @"我的群聊", @"imageName":@"icon_topic_as"}];
        
        __weak typeof(self)weakSelf = self;
        _menuView = [MenuView createMenuWithFrame:CGRectMake(0, 0, 150, dataArray.count * 40) target:self dataArray:dataArray itemsClickBlock:^(NSString *str, NSInteger tag) {
            if(tag==0){
                ScanCameraController *vc = [CommonMethod getVCFromNib:[ScanCameraController class]];
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }else if(tag==1){
                [weakSelf scanQRCode];
            }else if(tag==2){
                GroupSetUpViewController *vc = [CommonMethod getVCFromNib:[GroupSetUpViewController class]];
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }else if(tag==3){
                MyGroupViewController *myGroup = [[MyGroupViewController alloc]init];
                [self.navigationController pushViewController:myGroup animated:YES];
            }
            _menuShow = NO;
            _menuView = nil;
        } backViewTap:^{
            _menuShow = NO;
            _menuView = nil;
        }];
    }
    return _menuView;
}

- (void)updateVCDisplay{
    _currentTab = 0;
    
    self.dataArray1 = [NSMutableArray array];
    self.dataArray2 = [NSMutableArray array];
    self.dataArray3 = [NSMutableArray array];
    self.dataArray4 = [NSMutableArray array];
    
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64-49)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView tableViewAddUpLoadRefreshing:^{
        [self getHttpDataRecommend];
    }];
    
    [self.tableView tableViewAddDownLoadRefreshing:^{
        _currentTab = 0;
        [self.dataArray1 removeAllObjects];
        [self.dataArray2 removeAllObjects];
        [self.dataArray3 removeAllObjects];
        [self.dataArray4 removeAllObjects];
        [self.tagsArray removeAllObjects];
        [self getHttpDataRecommendIndustry];
    }];
    self.btnsView = self.btnView;
    
    [self getHttpDataRecommendIndustry];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(netWorkChange:) name:kReachabilityChangedNotification object:nil];
}

- (void)initTableHeaderView{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 200)];
    headerView.backgroundColor = kTableViewBgColor;

    CGFloat start_Y = 0;
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, start_Y, WIDTH, 44)];
    self.searchBar.showsCancelButton = NO;
    self.searchBar.returnKeyType = UIReturnKeySearch;
    self.searchBar.enablesReturnKeyAutomatically = YES;
    self.searchBar.delegate = self;
    [self.searchBar setPlaceholder:@"搜索"];
    [self.searchBar setSearchTextPositionAdjustment:UIOffsetMake(5, 0)];
    [self.searchBar setBackgroundColor:HEX_COLOR(@"E6E8EB")];
    [self.searchBar setBackgroundImage:kImageWithColor(HEX_COLOR(@"E6E8EB"), self.searchBar.bounds)];
    [self.searchBar setSearchFieldBackgroundImage:kImageWithName(@"searchBackground") forState:UIControlStateNormal];
    [self.searchBar setSearchFieldBackgroundImage:kImageWithName(@"searchBackground") forState:UIControlStateDisabled];
    self.searchBar.userInteractionEnabled = NO;
    [headerView addSubview:self.searchBar];
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = self.searchBar.frame;
    [searchBtn addTarget:self action:@selector(gotoSearchButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:searchBtn];
    start_Y += 44;
    
    //buttonviews
    self.btnsView.frame = CGRectMake(0, start_Y, WIDTH, 102);
    [CALayer updateControlLayer:self.friendApplyNumLabel.layer radius:9 borderWidth:1 borderColor:WHITE_COLOR.CGColor];
    self.friendApplyNumLabel.hidden = YES;
    [CALayer updateControlLayer:self.coffeeNumLabel.layer radius:9 borderWidth:1 borderColor:WHITE_COLOR.CGColor];
    self.coffeeNumLabel.hidden = YES;
    __weak typeof(self) weakSelf = self;
    self.cardRequestBlock = ^(NSNumber *number){
        weakSelf.friendApplyNumLabel.hidden = number.integerValue==0;
        weakSelf.friendApplyNumLabel.text = number.stringValue;
    };
    self.coffeeRequestBlock = ^(NSNumber *number){
        weakSelf.coffeeNumLabel.hidden = number.integerValue==0;
        weakSelf.coffeeNumLabel.text = number.stringValue;
    };
    [headerView addSubview:self.btnsView];
    start_Y += 102;
    
    //bannerview
    if(self.bannerModel && [NSDate daysAwayFromToday:[NSDate dateFromString:self.bannerModel.begintime format:kShortTimeFormat]]<=0 && [NSDate daysAwayFromToday:[NSDate dateFromString:self.bannerModel.endtime format:kShortTimeFormat]]>=0){
        start_Y += 10;
        UIButton *bannerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        bannerBtn.backgroundColor = WHITE_COLOR;
        bannerBtn.frame = CGRectMake(0, start_Y, WIDTH, 140);
        [bannerBtn addTarget:self action:@selector(bannerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [bannerBtn sd_setImageWithURL:[NSURL URLWithString:self.bannerModel.image] forState:UIControlStateNormal placeholderImage:KWidthImageDefault];
        [headerView addSubview:bannerBtn];
        start_Y += 140;
    }
    
    //推荐 tags
    if(self.tagsArray && self.tagsArray.count){
        start_Y += 10;
        CGFloat height = 193;
        if(self.tagsArray.count <= 4){
            height = 121;
        }
        UIView *rcmdView = [[UIView alloc] initWithFrame:CGRectMake(0, start_Y, WIDTH, height)];
        rcmdView.backgroundColor = WHITE_COLOR;
        [headerView addSubview:rcmdView];
        
        UILabel *rcmdLabel = [UILabel createrLabelframe:CGRectMake(0, 0, WIDTH, 49) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e") test:@"推荐" font:17 number:1 nstextLocat:NSTextAlignmentCenter];
        [rcmdView addSubview:rcmdLabel];
        
        CGFloat iconWidth = WIDTH/4;
        for(int i=0; i < self.tagsArray.count; i++){
            if(i == 8){
                break;
            }
            SubjectlistModel *model = self.tagsArray[i];
            UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake((iconWidth-32)/2+(i%4)*iconWidth, 49+i/4*73, 32, 32)];
            [iconImageView sd_setImageWithURL:[NSURL URLWithString:model.ios_icon2x] placeholderImage:KSquareImageDefault];
            iconImageView.contentMode = UIViewContentModeScaleAspectFill;
            [rcmdView addSubview:iconImageView];
            
            UILabel *iconLabel = [UILabel createrLabelframe:CGRectMake((iconWidth-64)/2+(i%4)*iconWidth, 93+i/4*71, 64, 12) backColor:WHITE_COLOR textColor:HEX_COLOR(@"999999") test:model.name font:12 number:1 nstextLocat:NSTextAlignmentCenter];
            [rcmdView addSubview:iconLabel];
            
            UIButton *iconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            iconBtn.frame = CGRectMake(iconWidth*(i%4), 49+i/4*73, iconWidth, 55);
            [iconBtn addTarget:self action:@selector(tagButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            iconBtn.tag = i;
            [rcmdView addSubview:iconBtn];
        }
        
        start_Y += height;
        UILabel *lineLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 0.5)];
        lineLabel1.backgroundColor = kCellLineColor;
        [rcmdView addSubview:lineLabel1];
        UILabel *lineLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, height-0.5, WIDTH, 0.5)];
        lineLabel2.backgroundColor = kCellLineColor;
        [rcmdView addSubview:lineLabel2];
    }
    
    //为你推荐的人脉
    UILabel *headerLabel = [UILabel createrLabelframe:CGRectMake(0, start_Y, WIDTH, 45) backColor:kTableViewBgColor textColor:HEX_COLOR(@"818C9E") test:@"为你推荐的人脉" font:17 number:1 nstextLocat:NSTextAlignmentCenter];
    [headerView addSubview:headerLabel];
    start_Y += 45;
    
    headerView.frame = CGRectMake(0, 0, WIDTH, start_Y);
    self.tableView.tableHeaderView = headerView;
}

#pragma mark - 点击按钮
- (IBAction)buttonClicked:(UIButton*)sender{
    if(sender.tag == 201){
        self.friendApplyNumLabel.hidden = YES;
        NewFriendsController *vc = [[NewFriendsController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if(sender.tag == 202){
        CardListViewController *vc = [[CardListViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
//        if(![[NSUserDefaults standardUserDefaults] boolForKey:NotFirstVisitingPhoneBook]){
//            VisitPhoneBookView *view = [CommonMethod getViewFromNib:@"VisitPhoneBookView"];
//            view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
//            view.visitPhoneBookViewResult = ^(BOOL result){
//                if(result){
//                    PhoneFriendsController *vc = [[PhoneFriendsController alloc] init];
//                    [self.navigationController pushViewController:vc animated:YES];
//                }
//            };
//            [[UIApplication sharedApplication].keyWindow addSubview:view];
//        }else{
//            PhoneFriendsController *vc = [[PhoneFriendsController alloc] init];
//            [self.navigationController pushViewController:vc animated:YES];
//        }
    }else if(sender.tag == 203){
        SearchCompanyViewController *vc = [[SearchCompanyViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if(sender.tag == 204){
        VistorsListViewController *vc = [[VistorsListViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if(sender.tag == 205){
        self.coffeeNumLabel.hidden = YES;
        MyCofferViewController *vc = [[MyCofferViewController alloc] init];
        vc.showBackBtn = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//标签
- (void)tagButtonClicked:(UIButton*)sender{
    SearchFriendListViewController *vc = [[SearchFriendListViewController alloc] init];
    SubjectlistModel *model = self.tagsArray[sender.tag];
    vc.searchStr = model.name;
    vc.searchType = @"users";
    [self.navigationController pushViewController:vc animated:YES];
}

//搜索
- (void)gotoSearchButtonClicked:(UIButton*)sender{
    SearchFriendViewController *vc = [CommonMethod getVCFromNib:[SearchFriendViewController class]];
    vc.isHideNavBack = YES;
    vc.view.transform = CGAffineTransformMakeTranslation(0, 64);
    vc.view.alpha = 0.8;
    [UIView animateWithDuration:0.3 animations:^{
        vc.view.alpha = 1;
        vc.view.transform = CGAffineTransformMakeTranslation(0, 0);
    }];
    [self.navigationController pushViewController:vc animated:NO];
}

//banner
- (void)bannerButtonClicked:(UIButton*)sender{
    //0.外链 1.资讯 2.活动 3.话题 4.场地 5.海报
    if(self.bannerModel.type.integerValue==0){
        DetaileViewController *vc = [[DetaileViewController alloc] init];
        vc.url = self.bannerModel.url;
        if([[CommonMethod paramStringIsNull:self.bannerModel.url] length]){
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else if(self.bannerModel.type.integerValue==1){
        InformationDetailController *vc = [[InformationDetailController alloc] init];
        vc.postID = [NSNumber numberWithInteger:self.bannerModel.url.integerValue];
        [self.navigationController pushViewController:vc animated:YES];
    }else if(self.bannerModel.type.integerValue==2){
        if([self.bannerModel.url hasPrefix:FristAdURL]){
            NSString *activityIDStr = [self.bannerModel.url substringFromIndex:[FristAdURL length]];
            NSNumber *activityID = [NSNumber numberWithInteger:activityIDStr.integerValue];
            ActivityDetailController *vc = [[ActivityDetailController alloc] init];
            vc.activityid = activityID;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else if(self.bannerModel.type.integerValue==3){
        TopicViewController *vc = [[TopicViewController alloc] init];
        vc.subjectId = [NSNumber numberWithInteger:self.bannerModel.url.integerValue];
        [self.navigationController pushViewController:vc animated:YES];
    }else if(self.bannerModel.type.integerValue==4){
        [self.navigationController pushViewController:[[CoffeeIntroduceViewController alloc] init] animated:YES];
    }else if(self.bannerModel.type.integerValue==5){
        PosterWebViewController *vc = [CommonMethod getVCFromNib:[PosterWebViewController class]];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//tab栏点击btn
- (void)tabButtonClicked:(UIButton*)sender{
    [self newThreadForAvoidButtonRepeatClick:sender];
    [self.tableView endRefresh];
    [self cancelAllRequest];
    [self.tableView setScrollsToTop:YES];
    UIView *view = sender.superview;
    _currentTab = sender.tag-300;
    for(int i = 0; i < 4; i++){
        UIButton *btn = (UIButton*)[view subviewWithTag:300+i];
        btn.selected = NO;
    }
    sender.selected = YES;
    
    UILabel *redLabel = (UILabel*)[view subviewWithTag:200];
    [UIView animateWithDuration:0.3 animations:^{
        redLabel.frame = CGRectMake((WIDTH/4-50)/2+_currentTab*(WIDTH/4), 41.5, 50, 1);
    }];
    
    CGFloat headerViewHeight = self.tableView.tableHeaderView.frame.size.height;
    [self.tableView reloadData];
    if(self.tableView.contentOffset.y > headerViewHeight){
        [self.tableView setContentOffset:CGPointMake(0, headerViewHeight) animated:NO];
    }
    
    UserModel *model = [DataModelInstance shareInstance].userModel;
    NSMutableArray *array = [NSMutableArray array];
    if(_currentTab == 0){
        array = self.dataArray1;
    }else if(_currentTab == 1){
        if([CommonMethod paramStringIsNull:model.industry].length==0){
            self.tableView.mj_footer.hidden = YES;
            [self.dataArray2 removeAllObjects];
            [self.tableView reloadData];
            return;
        }
        array = self.dataArray2;
    }else if(_currentTab == 2){
        if([CommonMethod paramStringIsNull:model.position].length==0){
            self.tableView.mj_footer.hidden = YES;
            [self.dataArray3 removeAllObjects];
            [self.tableView reloadData];
            return;
        }
        array = self.dataArray3;
    }else if(_currentTab == 3){
        if([CommonMethod paramStringIsNull:model.company].length==0){
            self.tableView.mj_footer.hidden = YES;
            [self.dataArray4 removeAllObjects];
            [self.tableView reloadData];
            return;
        }
        array = self.dataArray4;
    }
    if(array.count==0){
        self.tableView.mj_footer.hidden = NO;
        [self.tableView.mj_footer resetNoMoreData];
        [self getHttpDataRecommend];
    }else{
        if(array.count%20){
            [self.tableView endRefreshNoData];
        }else{
            [self.tableView.mj_footer resetNoMoreData];
        }
        [self.tableView reloadData];
    }
}

#pragma mark - 网络变化
- (void)netWorkChange:(NSNotification *)netWorkChange{
    Reachability *reach = [netWorkChange object];
    [self showNetWorkStatue:reach.currentReachabilityStatus!=NotReachable];
}

- (void)showNetWorkStatue:(BOOL)hasNet{
    NSMutableArray *array = [NSMutableArray array];
    if(_currentTab == 0){
        array = self.dataArray1;
    }else if(_currentTab == 1){
        array = self.dataArray2;
    }else if(_currentTab == 2){
        array = self.dataArray3;
    }else if(_currentTab == 3){
        array = self.dataArray4;
    }
    if (!hasNet) {
        if (array && self.showBtnNotWork==nil) {
            self.showBtnNotWork = [UIButton buttonWithType:UIButtonTypeCustom];
            self.showBtnNotWork.frame = CGRectMake(0, 0, WIDTH, 36);
            [self.tableView addSubview:self.showBtnNotWork];
            [self.showBtnNotWork setTitle:@"没有网络连接，请检查网络设置" forState:UIControlStateNormal];
            [self.showBtnNotWork setTitleColor:[UIColor colorWithHexString:@"8B4542"] forState:UIControlStateNormal];
            self.showBtnNotWork.titleLabel.font = [UIFont systemFontOfSize:14];
            self.showBtnNotWork.backgroundColor = [UIColor colorWithHexString:@"FFE1E1"];
        }
    }else{
        if(self.showBtnNotWork){
            [self.showBtnNotWork removeFromSuperview];
            self.showBtnNotWork = nil;
            if(self.bannerModel==nil){
                [self getHttpDataRecommendIndustry];
            }else if (array.count == 0) {
                [self getHttpDataRecommend];
            }
        }
    }
}

#pragma mark --- 网络请求数据－推荐行业和海报
- (void)getHttpDataRecommendIndustry{
    __weak typeof(self) weakSelf = self;
    [self requstType:RequestType_Get apiName:API_NAME_GET_USER_RECOMINDUSTRY paramDict:nil hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [weakSelf.tableView endRefresh];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSDictionary *dict = [CommonMethod paramDictIsNull:responseObject[@"data"]];
            weakSelf.bannerModel = [[BannerModel alloc] initWithDict:[CommonMethod paramDictIsNull:dict[@"banner"]]];
            if(!weakSelf.tagsArray){
                weakSelf.tagsArray = [NSMutableArray array];
            }
            NSArray *array = [CommonMethod paramArrayIsNull:dict[@"tags"]];
            for(NSDictionary *tag in array){
                SubjectlistModel *model = [[SubjectlistModel alloc] initWithDict:tag];
                [weakSelf.tagsArray addObject:model];
            }
            [weakSelf initTableHeaderView];
            [weakSelf getHttpDataRecommend];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [weakSelf.tableView endRefresh];
        [weakSelf showNetWorkStatue:[CommonMethod webIsLink]];
        [weakSelf initTableHeaderView];
        [weakSelf getHttpDataRecommend];
    }];
}

#pragma mark --- 网络请求数据－人脉推荐，同行1，同职2，同事3
- (void)getHttpDataRecommend{
    _noNetWork = NO;
    NSMutableArray *array = [NSMutableArray array];
    if(_currentTab == 0){
        array = self.dataArray1;
    }else if(_currentTab == 1){
        array = self.dataArray2;
    }else if(_currentTab == 2){
        array = self.dataArray3;
    }else if(_currentTab == 3){
        array = self.dataArray4;
    }
    
    NSString *apiStr = API_NAME_GET_USER_CONNECTION;
    RequestType type = RequestType_Get;
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    if(array.count == 0){
        _isLoadHttp = YES;
        [self.tableView reloadData];
    }
    
    if(_currentTab == 0){
        type = RequestType_Post;
        [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
        apiStr = API_NAME_POST_USER_RECOMLIST;
        if(self.dataArray1.count){
            NSMutableArray *paramArray = [NSMutableArray array];
            for(ContactsModel *model in self.dataArray1){
                [paramArray addObject:model.userid];
            }
            [requestDict setObject:[paramArray componentsJoinedByString:@","] forKey:@"ignoreids"];
        }else{
            [requestDict setObject:@"" forKey:@"ignoreids"];
        }
    }else if(_currentTab == 1){
        NSInteger page = self.dataArray2.count/20+(self.dataArray2.count%20||self.dataArray2.count?1:0);
        page = page?page:1;
        [requestDict setObject:[NSString stringWithFormat:@"/%@/%@/%@", [DataModelInstance shareInstance].userModel.userId, @(_currentTab), @(page)] forKey:@"param"];
    }else if(_currentTab == 2){
        NSInteger page = self.dataArray3.count/20+(self.dataArray3.count%20||self.dataArray3.count?1:0);
        page = page?page:1;
        [requestDict setObject:[NSString stringWithFormat:@"/%@/%@/%@", [DataModelInstance shareInstance].userModel.userId, @(_currentTab), @(page)] forKey:@"param"];
    }else if(_currentTab == 3){
        NSInteger page = self.dataArray4.count/20+(self.dataArray4.count%20||self.dataArray4.count?1:0);
        page = page?page:1;
        [requestDict setObject:[NSString stringWithFormat:@"/%@/%@/%@", [DataModelInstance shareInstance].userModel.userId, @(_currentTab), @(page)] forKey:@"param"];
    }
    __block int tmpTabIndex = _currentTab;
    [self requstType:type apiName:apiStr paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _isLoadHttp = NO;
            if([CommonMethod isHttpResponseSuccess:responseObject]){
                NSArray *tmpArray = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
                NSMutableArray *array = [NSMutableArray array];
                for(NSDictionary *dict in tmpArray){
                    ContactsModel *model = [[ContactsModel alloc] initWithDict:dict];
                    [array addObject:model];
                }
                if(tmpTabIndex == 0){
                    [weakSelf.dataArray1 addObjectsFromArray:array];
                }else if(tmpTabIndex == 1){
                    [weakSelf.dataArray2 addObjectsFromArray:array];
                }else if(tmpTabIndex == 2){
                    [weakSelf.dataArray3 addObjectsFromArray:array];
                }else if(tmpTabIndex == 3){
                    [weakSelf.dataArray4 addObjectsFromArray:array];
                }
                if (array.count != 20) {
                    [weakSelf.tableView endRefreshNoData];
                }else{
                    [weakSelf.tableView endRefresh];
                }
                [weakSelf.tableView reloadData];
            }else{
                [weakSelf.tableView endRefresh];
                [weakSelf.tableView reloadData];
            }
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [weakSelf.tableView endRefresh];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _isLoadHttp = NO;
            _noNetWork = YES;
            [weakSelf.tableView reloadData];
            [weakSelf showNetWorkStatue:[CommonMethod webIsLink]];
        });
    }];
}

#pragma mark -- UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSMutableArray *array = [NSMutableArray array];
    if(_currentTab == 0){
        array = self.dataArray1;
    }else if(_currentTab == 1){
        array = self.dataArray2;
    }else if(_currentTab == 2){
        array = self.dataArray3;
    }else if(_currentTab == 3){
        array = self.dataArray4;
    }
    if(array.count){
        self.tableView.mj_footer.hidden = NO;
        return array.count;
    }else{
        self.tableView.mj_footer.hidden = YES;
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 43;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *tabView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 43)];
    tabView.backgroundColor = WHITE_COLOR;
    CGFloat tabWidth = WIDTH/4;
    NSArray *titles = @[@"推荐",@"同行",@"同职",@"同事"];
    for(int i = 0; i < 4; i++){
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(tabWidth*i, 0, tabWidth, 43);
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [btn setTitleColor:HEX_COLOR(@"818c9e") forState:UIControlStateNormal];
        [btn setTitleColor:HEX_COLOR(@"41464e") forState:UIControlStateSelected];
        btn.tag = i+300;
        btn.titleLabel.font = FONT_SYSTEM_SIZE(15);
        [btn addTarget:self action:@selector(tabButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [tabView addSubview:btn];
        if(i == _currentTab){
            btn.selected = YES;
            UILabel *redLabel = [[UILabel alloc] initWithFrame:CGRectMake((tabWidth-50)/2+i*tabWidth, 41.5, 50, 1)];
            redLabel.backgroundColor = HEX_COLOR(@"e23608");
            redLabel.tag = 200;
            [tabView addSubview:redLabel];
        }
        if(i < 3){
            UILabel *vLineLabel = [[UILabel alloc] initWithFrame:CGRectMake((i+1)*tabWidth-0.5, 14, 0.5, 14)];
            vLineLabel.backgroundColor = kCellLineColor;
            [tabView addSubview:vLineLabel];
        }
    }
    UILabel *lineLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 0.5)];
    lineLabel1.backgroundColor = kCellLineColor;
    [tabView addSubview:lineLabel1];
    UILabel *lineLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 42.5, WIDTH, 0.5)];
    lineLabel2.backgroundColor = kCellLineColor;
    [tabView addSubview:lineLabel2];
    return tabView;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *array = [NSMutableArray array];
    if(_currentTab == 0){
        array = self.dataArray1;
    }else if(_currentTab == 1){
        array = self.dataArray2;
    }else if(_currentTab == 2){
        array = self.dataArray3;
    }else if(_currentTab == 3){
        array = self.dataArray4;
    }
    if(array.count == 0){
        return self.tableView.frame.size.height-202>350?self.tableView.frame.size.height-202:350;
    }else{
        ContactsModel *model = array[indexPath.row];
        return model.cellHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *array = [NSMutableArray array];
    if(_currentTab == 0){
        array = self.dataArray1;
    }else if(_currentTab == 1){
        array = self.dataArray2;
    }else if(_currentTab == 2){
        array = self.dataArray3;
    }else if(_currentTab == 3){
        array = self.dataArray4;
    }
    if(array.count == 0){
        return self.tableView.frame.size.height-202>350?self.tableView.frame.size.height-202:350;
    }else{
        ContactsModel *model = array[indexPath.row];
        return model.cellHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *array = [NSMutableArray array];
    if(_currentTab == 0){
        array = self.dataArray1;
    }else if(_currentTab == 1){
        array = self.dataArray2;
    }else if(_currentTab == 2){
        array = self.dataArray3;
    }else if(_currentTab == 3){
        array = self.dataArray4;
    }
    if(array.count == 0){
        if(_isLoadHttp){
            static NSString *cellID = @"ContactsLoadDataView";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            for(UIView *view in cell.contentView.subviews){
                if (view.tag == 200) {
                    ContactsLoadDataView *loadView = (ContactsLoadDataView*)[view viewWithTag:300];
                    if(loadView){
                        [loadView stopProgressing];
                    }
                }
            }
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, self.tableView.frame.size.height-202>350?self.tableView.frame.size.height-202:350)];
            view.tag = 200;
            ContactsLoadDataView *loadDataView = [CommonMethod getViewFromNib:NSStringFromClass([ContactsLoadDataView class])];
            loadDataView.frame = CGRectMake(0, 0, WIDTH, self.tableView.frame.size.height-202>350?self.tableView.frame.size.height-202:350);
            [loadDataView startProgressing];
            loadDataView.tag = 300;
            [view addSubview:loadDataView];
            [cell.contentView addSubview:view];
            return cell;
        }else if(_noNetWork){
            static NSString *cellID = @"NONetWorkTableViewCell";
            NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [CommonMethod getViewFromNib:NSStringFromClass([NONetWorkTableViewCell class])];
            }
            return cell;
        }else{
            static NSString *cellID = @"NODataTableViewCell";
            NODataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [CommonMethod getViewFromNib:NSStringFromClass([NODataTableViewCell class])];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            UserModel *model = [DataModelInstance shareInstance].userModel;
            if([CommonMethod paramStringIsNull:model.industry].length==0 || [CommonMethod paramStringIsNull:model.position].length==0 || [CommonMethod paramStringIsNull:model.company].length==0){
                cell.mainLabel.text = @"完善个人信息";
                cell.subLabel.text = @"推荐优质人脉";
                [cell.btnImageView setBackgroundImage:kImageWithName(@"btn_bg_red") forState:UIControlStateNormal];
                [cell.btnImageView setTitle:@"完善信息" forState:UIControlStateNormal];
                [cell.btnImageView setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
                cell.btnImageView.hidden = NO;
                cell.coverImageView.image = kImageWithName(@"icon_authentication_identity");
                __weak typeof(self) weakSelf = self;
                cell.clickButton = ^(){
                    EditPersonalInfoViewController *vc = [[EditPersonalInfoViewController alloc] init];
                    vc.savePersonalInfoSuccess = ^{
                        [weakSelf getHttpDataRecommend];
                    };
                    [self.navigationController pushViewController:vc animated:YES];
                };
            }else{
                cell.mainLabel.text = @"暂未找到相关人脉";
                cell.subLabel.text = @"赶快邀请好友加入3号圈";
                [cell.btnImageView setBackgroundImage:kImageWithName(@"btn_bg_red") forState:UIControlStateNormal];
                [cell.btnImageView setTitle:@"邀请好友" forState:UIControlStateNormal];
                [cell.btnImageView setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
                cell.btnImageView.hidden = NO;
                cell.coverImageView.image = kImageWithName(@"icon_no_shaixuan_b");
                cell.clickButton = ^(){
                    if(![[NSUserDefaults standardUserDefaults] boolForKey:NotFirstVisitingPhoneBook]){
                        VisitPhoneBookView *view = [CommonMethod getViewFromNib:@"VisitPhoneBookView"];
                        view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
                        view.visitPhoneBookViewResult = ^(BOOL result){
                            if(result){
                                PhoneFriendsController *vc = [[PhoneFriendsController alloc] init];
                                [self.navigationController pushViewController:vc animated:YES];
                            }
                        };
                        [[UIApplication sharedApplication].keyWindow addSubview:view];
                    }else{
                        PhoneFriendsController *vc = [[PhoneFriendsController alloc] init];
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                };
            }
            return cell;
        }
    }else{
        static NSString *cellID = @"ContactsCell";
        ContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([ContactsCell class])];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        NSMutableArray *array = [NSMutableArray array];
        if(_currentTab == 0){
            array = self.dataArray1;
        }else if(_currentTab == 1){
            array = self.dataArray2;
        }else if(_currentTab == 2){
            array = self.dataArray3;
        }else if(_currentTab == 3){
            array = self.dataArray4;
        }
        ContactsModel *model = array[indexPath.row];
        [cell updateDisplay:model];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableArray *array = [NSMutableArray array];
    if(_currentTab == 0){
        array = self.dataArray1;
    }else if(_currentTab == 1){
        array = self.dataArray2;
    }else if(_currentTab == 2){
        array = self.dataArray3;
    }else if(_currentTab == 3){
        array = self.dataArray4;
    }
    if(array.count == 0 && _noNetWork){
        if(self.bannerModel){
            _isLoadHttp = YES;
            [self.tableView reloadData];
            [self getHttpDataRecommend];
        }else{
            [self getHttpDataRecommendIndustry];
        }
        return;
    }else if(array.count){
        NewMyHomePageController *myhome = [[NewMyHomePageController alloc]init];
        ContactsModel *model = array[indexPath.row];
        myhome.userId = model.userid;
        [self.navigationController pushViewController:myhome animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    if(scrollView.contentOffset.y<0){
//        [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
//    }
//}
//
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
//    if(scrollView.contentOffset.y<0){
//        [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
//    }
//}

@end
