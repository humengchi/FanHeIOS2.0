//
//  ActivityDetailController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/30.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ActivityDetailController.h"
#import "MyAskAboutActivity.h"
#import "ReportViewController.h"
#import "TickerDetailController.h"
#import "DelectDataView.h"
#import "NONetWorkTableViewCell.h"
#import "TicketController.h"
#import "MenuView.h"

#import "TitleViewCell.h"
#import "ActivityAddCell.h"
#import "ActivityApplyCell.h"
#import "ActifityReportCell.h"
#import "AddressCell.h"
#import "ActivityGuestsCell.h"
#import "ActivityAskCell.h"

#import "WebViewController.h"

#import "FinanaceDetailModel.h"
#import "InformationDetailController.h"
#import "LocationMapController.h"
#import "ApplyActivityController.h"
#import "ChoiceFriendViewController.h"
#import "ActivityManagerViewController.h"
#import "TopicIdentifyViewController.h"
#import "DynamicShareView.h"
#import "TransmitDynamicController.h"
#import "VideoUrlController.h"

#import "TicketListViewController.h"

@interface ActivityDetailController ()<UIWebViewDelegate,MWPhotoBrowserDelegate,MyAskAboutActivityDelegate,TitleViewCellDelegate>
@property (weak, nonatomic) IBOutlet UILabel *sideActivityLabel;
@property (weak, nonatomic) IBOutlet UILabel *applyLabel;
@property (weak, nonatomic) IBOutlet UIView *footView;
@property (weak, nonatomic) IBOutlet UIButton *applyBtn;
@property (nonatomic ,assign) BOOL netWorkStat;
@property (nonatomic ,strong) DelectDataView *delectView;
@property (nonatomic ,strong) MenuView * menuView;
@property (nonatomic ,strong) UIView *backHeaderView;
@property (nonatomic ,strong) UIButton *recommendBtn;
@property (nonatomic ,strong) UIView *tabBarView;
@property (nonatomic ,strong) UIButton *backBtn;
@property (nonatomic ,strong) UILabel  *titleTabBaeLabel;
@property (nonatomic ,strong) UIButton *editBtn;
@property (nonatomic ,strong) UIImageView  *headerImageView;
@property (nonatomic ,strong) UIView *headerView;
@property (nonatomic ,strong) MyActivityModel *activityModel;
@property (nonatomic ,strong) UserModel *userModel;
@property (nonatomic ,strong) UIWebView *webView;
@property (nonatomic ,strong) NSMutableArray *imageArray;
@property (nonatomic ,assign) CGFloat heigth;
//报名人
@property (nonatomic ,strong) NSMutableArray *applyArray;
//嘉宾
@property (nonatomic ,strong) NSMutableArray *guestArray;
//回答
@property (nonatomic ,strong) NSMutableArray *askArray;
//门票
@property (nonatomic ,strong) NSMutableArray *tickrtArray;
@property (nonatomic ,assign) BOOL flag;
@property (nonatomic,strong) UIView *coverView;

@property (nonatomic,strong) UIImageView *addressImageView;
@property (nonatomic,assign) NSInteger page;
@property (nonatomic,assign)  BOOL isPresentVC;

@end

@implementation ActivityDetailController
// 作用：拦截手势触发
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if(self.flag == NO){
        [self.menuView showMenuWithAnimation:NO];
        self.flag = YES;
        self.menuView = nil;
        return NO;
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
    _isPresentVC = NO;
    self.netWorkStat = NO;
    self.applyArray = [NSMutableArray new];
    self.guestArray = [NSMutableArray new];
    self.askArray = [NSMutableArray new];
    self.tickrtArray = [NSMutableArray new];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if([[UIApplication sharedApplication] statusBarStyle] == UIStatusBarStyleDefault && _isPresentVC == NO) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
     UserModel *model = [DataModelInstance shareInstance].userModel;
     [[AppDelegate shareInstance] setZhugeTrack:@"活动详情" properties:@{@"useID":[CommonMethod paramNumberIsNull:model.userId], @"position":[CommonMethod paramStringIsNull:model.position],@"address":[CommonMethod paramStringIsNull:model.city],@"goodAt":[[CommonMethod paramArrayIsNull:model.goodjobs]componentsJoinedByString:@","],@"industry":[CommonMethod paramStringIsNull:model.industry]}];
    
    self.page = 1;
    _isPresentVC = NO;
    self.applyLabel.hidden = YES;
    self.sideActivityLabel.hidden = YES;
    self.applyBtn.layer.masksToBounds = YES;
    self.applyBtn.layer.cornerRadius = 5.0;
    self.addressImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, WIDTH*114/375)];
    self.flag = YES;
    
    [self createrTabBerView];
    
    [self getSubjectTalkFianaceDetailData];
    [self getAskActivityDetailData:self.page];
    
    [self getTickerAll];
}

#pragma mark ------  获取专访列表数据
- (void)getSubjectTalkFianaceDetailData{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@",self.activityid, [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_ACTIVITY_MYACTIVITYDETAIL paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [weakSelf.tableView endRefresh];
        weakSelf.netWorkStat = NO;
        [hud hideAnimated:YES];
        if (self.guestArray.count > 0 ) {
            [self.guestArray removeAllObjects];
        }
        if (self.applyArray.count > 0 ) {
            [self.applyArray removeAllObjects];
        }
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSDictionary *dict = [CommonMethod paramDictIsNull:[responseObject objectForKey:@"data"]];
            weakSelf.activityModel = [[MyActivityModel alloc] initWithDict:dict];
            weakSelf.activityModel.content = dict[@"report"][@"content"];
            weakSelf.activityModel.postid = dict[@"report"][@"postid"];
            weakSelf.activityModel.title = dict[@"report"][@"title"];
            weakSelf.activityModel.applystr = dict[@"apply"][@"str"];
            NSDictionary *applyDic = [CommonMethod paramDictIsNull:[dict objectForKey:@"apply"]];
            NSArray *applyArray = [CommonMethod paramArrayIsNull:[applyDic objectForKey:@"lists"]];
            for (NSDictionary *applyDic  in applyArray) {
                weakSelf.userModel = [[UserModel alloc] initWithDict:applyDic];
                [weakSelf.applyArray addObject:weakSelf.userModel];
            }
            NSArray *guestSubArray = [CommonMethod paramArrayIsNull:[dict objectForKey:@"guests"]];
            for (NSDictionary *guestDic in guestSubArray) {
                UserModel *model = [[UserModel alloc] initWithDict:guestDic];
                [weakSelf.guestArray addObject:model];
            }
            weakSelf.userModel = [[UserModel alloc] initWithDict:dict[@"userinfo"]];
            self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 16, WIDTH- 32, 1)];
            self.webView.delegate = self;
            self.webView.scrollView.scrollEnabled = NO;
            [self.webView setScalesPageToFit:YES];
            //             预先加载url
            [self.webView loadHTMLString:self.activityModel.contents baseURL:[[NSBundle mainBundle] resourceURL]];
            
            //
            [self.addressImageView sd_setImageWithURL:[NSURL URLWithString:self.activityModel.placeimg] placeholderImage:KWidthImageDefault];
            
            //诸葛监控
            [[AppDelegate shareInstance] setZhugeTrack:@"浏览活动" properties:@{@"postID": [CommonMethod paramNumberIsNull:self.activityid], @"activityName":[CommonMethod paramStringIsNull:self.activityModel.name] ,@"tag":[[CommonMethod paramArrayIsNull:self.activityModel.tags]  componentsJoinedByString:@","]}];
            
            
            if (self.activityModel.status.integerValue == 6 ) {
                self.applyBtn.userInteractionEnabled = YES;
                [self.applyBtn setTitle:@"活动直播" forState:UIControlStateNormal];
                [self.applyBtn setBackgroundColor:[UIColor colorWithHexString:@"1ABC9C"]];
            }else{
                if (self.activityModel.status.integerValue == 5 || self.activityModel.status.integerValue == 7) {
                    self.applyBtn.userInteractionEnabled = YES;
                    if (self.activityModel.online_info.length > 0) {
                        [self.applyBtn setTitle:@"" forState:UIControlStateNormal];
                        self.applyLabel.hidden = NO;
                        self.sideActivityLabel.hidden = NO;
                        [self.applyBtn setBackgroundColor:[UIColor colorWithHexString:@"1ABC9C"]];
                    }else{
                        [self.applyBtn setTitle:@"我要报名" forState:UIControlStateNormal];
                        [self.applyBtn setBackgroundColor:[UIColor colorWithHexString:@"1ABC9C"]];
                    }
                }else if (self.activityModel.status.integerValue == 1 ){
                    [self.applyBtn setTitle:@"活动已结束" forState:UIControlStateNormal];
                    [self.applyBtn setBackgroundColor:[UIColor colorWithHexString:@"E6E8EB"]];
                    self.applyBtn.userInteractionEnabled=NO;
                }else if (self.activityModel.status.integerValue == 2 ){
                    [self.applyBtn setTitle:@"活动已取消" forState:UIControlStateNormal];
                    [self.applyBtn setBackgroundColor:[UIColor colorWithHexString:@"E6E8EB"]];
                    self.applyBtn.userInteractionEnabled=NO;
                }else if (self.activityModel.status.integerValue == 3 ){
                    [self.applyBtn setTitle:@"报名已截止" forState:UIControlStateNormal];
                    [self.applyBtn setBackgroundColor:[UIColor colorWithHexString:@"E6E8EB"]];
                    self.applyBtn.userInteractionEnabled=NO;
                }else if (self.activityModel.status.integerValue == 4 ){
                    [self.applyBtn setTitle:@"已报名" forState:UIControlStateNormal];
                    [self.applyBtn setBackgroundColor:[UIColor colorWithHexString:@"E6E8EB"]];
                    self.applyBtn.userInteractionEnabled=NO;
                }
            }
            [self createrTabView];
            [self createrTabHeaderView];
            [weakSelf.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [weakSelf.tableView endRefresh];
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        weakSelf.netWorkStat = YES;
        [weakSelf.tableView reloadData];
    }];
}
#pragma mark ------  获取问答表数据
- (void)getAskActivityDetailData:(NSInteger)page{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%ld",self.activityid,page] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_ACTIVITY_ACTIVITYASKLIST paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if (page == 1) {
            [weakSelf.askArray removeAllObjects];
        }
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array =  [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            if(array.count==0){
                [weakSelf.tableView endRefreshNoData];
            }else{
                [weakSelf.tableView endRefresh];
            }
            for (NSDictionary *subDic in array) {
                UserModel *model = [[UserModel alloc] initWithDict:subDic];
                [weakSelf.askArray addObject:model];
            }
            [weakSelf.tableView reloadData];
        }else{
            [weakSelf.tableView endRefresh];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [weakSelf.tableView endRefresh];
        [hud hideAnimated:YES];
    }];
}

#pragma mark -------  创建导航
- (void)createrTabBerView{
    if (self.backHeaderView) {
        [self.backHeaderView removeFromSuperview];
    }
    self.backHeaderView = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, 64) backColor:nil];
    self.backHeaderView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.backHeaderView];
    
    self.tabBarView = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, 64) backColor:nil];
    self.tabBarView.backgroundColor = [UIColor whiteColor];
    self.tabBarView.alpha = 0;
    [self.backHeaderView addSubview:self.tabBarView];
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 63.5, WIDTH, 0.5)];
    lineLabel.backgroundColor = kCellLineColor;
    [self.tabBarView addSubview:lineLabel];
    
    self.backBtn = [NSHelper createButton:CGRectMake(0, 20, 64, 44) title:nil unSelectImage:[UIImage imageNamed:@"btn_tab_back_normal"] selectImage:nil target:self selector:@selector(backBtnAction)];
    [self.backHeaderView addSubview:self.backBtn];
    self.recommendBtn = [NSHelper createButton:CGRectMake(WIDTH - 40 , 26, 32, 32) title:nil unSelectImage:[UIImage imageNamed:@"btn_tab_more_normal"] selectImage:nil target:self selector:@selector(recommendBtnAction)];
    [self.backHeaderView addSubview:self.recommendBtn];
    self.titleTabBaeLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 26, WIDTH - 80, 30)];
    self.titleTabBaeLabel.text = @"活动详情";
    self.titleTabBaeLabel.hidden = YES;
    self.titleTabBaeLabel.textAlignment = NSTextAlignmentCenter;
    [self.backHeaderView addSubview:self.titleTabBaeLabel];
}
#pragma mark ----  举报
- (void)recommendBtnAction{
    if (self.flag) {
        [self.menuView showMenuWithAnimation:YES];
        self.flag = NO;
    }else{
        [self.menuView showMenuWithAnimation:NO];
        self.flag = YES;
        self.menuView = nil;
    }
}
//弹出下拉菜单
- (MenuView *)menuView{
    if (!_menuView) {
        NSArray *dataArray = [NSArray new];
        if (self.userModel.userId.integerValue == [DataModelInstance shareInstance].userModel.userId.integerValue) {
            dataArray = @[@{@"itemName" : @"活动管理"},@{@"itemName" : @"分享"}];
        }else{
            dataArray = @[@{@"itemName" : @"分享"},@{@"itemName" : @"举报"}];
            
        }
        CGFloat x = self.view.bounds.size.width / 3 * 2 -15;
        CGFloat y = 66+7;
        CGFloat width = self.view.bounds.size.width * 0.3 +20;
        CGFloat height = dataArray.count * 40;
        __weak __typeof(&*self)weakSelf = self;
        _menuView = [MenuView createMenuWithFrame:CGRectMake(x, y, width, height) target:self dataArray:dataArray itemsClickBlock:^(NSString *str, NSInteger tag){
            if (self.userModel.userId.integerValue == [DataModelInstance shareInstance].userModel.userId.integerValue) {
                if (tag == 0) {
                    ActivityManagerViewController *activity = [[ActivityManagerViewController alloc]init];
                    activity.activityid = self.activityid;
                    [self.navigationController pushViewController:activity animated:YES];
                }else{
                    [self sharViewActivity];
                }
                
            }else{
                [weakSelf gotoReportActivityAction:tag];
            }
        } backViewTap:^{
            _menuView = nil;
        }];
    }
    return _menuView;
}
#pragma mark -----  去举报
-(void)gotoReportActivityAction:(NSInteger)tag{
    if (tag == 0) {
        [self sharViewActivity];
    }else{
        ReportViewController *report = [[ReportViewController alloc]init];
        report.reportType = ReportType_Activity;
        report.reportId = self.activityid;
        [self.navigationController pushViewController:report animated:YES];
        
    }
    self.flag = YES;
    [self.menuView showMenuWithAnimation:NO];
    self.menuView = nil;
}

- (void)createrTabView{
    [self initTableView:CGRectMake(0, 0, WIDTH,HEIGHT - 49)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView tableViewAddDownLoadRefreshing:^{
        self.page = 1;
        [self getSubjectTalkFianaceDetailData];
        [self getAskActivityDetailData:self.page];
    }];
    [self.tableView tableViewAddUpLoadRefreshing:^{
        self.page ++;
        [self getAskActivityDetailData:self.page];
    }];
    [self createrTabBerView];
}

- (void)backBtnAction{
    if (_menuView) {
        [self.menuView showMenuWithAnimation:NO];
        _menuView = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createrTabHeaderView{
    //头视图
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, WIDTH*9/16)];
    self.headerView.userInteractionEnabled = YES;
    self.tableView.tableHeaderView = self.headerView;
    UIImageView *imageView = [UIImageView drawImageViewLine:CGRectMake(0, 0, WIDTH, WIDTH*9/16) bgColor:[UIColor grayColor]];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [self.headerView addSubview:imageView];
    self.headerImageView = imageView;
    [imageView sd_setImageWithURL:[NSURL URLWithString:self.activityModel.image] placeholderImage:KWidthImageDefault];
}

#pragma mark ----- 数据被删除
- (void)delectNewDetail{
    [self.scrollView removeFromSuperview];
    self.delectView = [CommonMethod getViewFromNib:NSStringFromClass([DelectDataView class])];
    self.delectView.frame = CGRectMake(0, 64, WIDTH, HEIGHT);
    [self.view addSubview:self.delectView];
}

#pragma mark - UITableViewDelegate/DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.netWorkStat == YES){
        return 1;
    }else if (section == 0) {
        return 1;
    }else if (section == 1) {//活动报道
        if (self.activityModel.title.length > 0 ) {
            return 1;
        }else{
            return 0;
        }
    }else if (section == 2) {
        return 1;
    }else if (section == 3) {
        return 1;
    }else if (section == 4) {//报名人
        if (self.applyArray.count > 0 ) {
            return 1;
        }else{
            return 0;
        }
    }else if (section == 5) {
        return 1;
    }else if (section == 6) {//嘉宾
        return self.guestArray.count;
    }else if (section == 7) {//场地
        if (self.activityModel.addresstype.integerValue == 1) {
            return 1;
        }else{
            return 0;
        }
    }
    return self.askArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES){
        return self.tableView.frame.size.height;
    }else if (indexPath.section == 0) {
        return [TitleViewCell backTitleViewCellHeigth:self.activityModel];
    }else if (indexPath.section == 2) { //地址
        return  [AddressCell backAddressCellHeigth:self.activityModel];
    }else if (indexPath.section == 3) {//活动费用
        return 169;
    }else if (indexPath.section == 4) {//报名人
        if (self.applyArray.count > 0 ) {
            return 66;
        }else{
            return 0;
        }
    }else if (indexPath.section == 1) {//活动报道
        if (self.activityModel.title.length > 0 ) {
            return 64;
        }else{
            return 0;
        }
    }else if (indexPath.section == 5) {//活动介绍
        return  self.heigth+16;
    }else if (indexPath.section == 6) {//嘉宾
        UserModel *model = self.guestArray[indexPath.row];
        return [ActivityGuestsCell backActivityGuestsCellHeigth:model];
    }else if (indexPath.section == 7) {//场地
        if (self.activityModel.addresstype.integerValue == 1) {
            return WIDTH*114/375;
        }else{
            return 0;
        }
    }else{
        UserModel *model = self.askArray[indexPath.row];
        return [ActivityAskCell backActivityAskCellHeigth:model];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(self.netWorkStat == YES){
        return 1;
    }
    return 9;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }else if (section == 1){ //活动报道
        if (self.activityModel.title.length > 0 ) {
            return 5;
        }else{
            return 0;
        }
    }else if (section == 2){
        return 5;
    }else if (section == 3){
        return 0;
    }else if (section == 4){
        if (self.applyArray.count > 0 ) {
            return 5;
        }else{
            return 0;
        }
    }else if (section == 5){
        return 51;
    }else if (section == 6){
        if (self.guestArray.count == 0) {
            return 0;
        }else{
            return 51;
        }
    }else if (section == 7) {//场地
        if (self.activityModel.addresstype.integerValue == 1) {
            return 5;
        }else{
            return 0;
        }
    }else if (section == 8){
        return 51+66;
    }
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CGFloat heigth = 10;
    if (section == 5 || section == 6) {
        heigth = 51;
    }
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, heigth)];
    view.backgroundColor = HEX_COLOR(@"EFEFF4");
    NSString *rateCount;
    if (self.activityModel.asknum.integerValue > 0) {
        rateCount = [NSString stringWithFormat:@"问答(%@)",self.activityModel.asknum];
    }else{
        rateCount = @"问答";
    }
    UIView *lineView1 = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, 0.5) backColor:@"D9D9D9"];
    [view addSubview:lineView1];
    NSArray *array = @[@"活动介绍",@"嘉宾",@"",rateCount];
    if (section == 5 || section == 6 || section == 8) {
        UIView *bavkView = [NSHelper createrViewFrame:CGRectMake(0, 5, WIDTH, 46) backColor:@"FFFFFF"];
        UILabel *titleLabel = [UILabel createLabel:CGRectMake(16, 16, WIDTH - 20, 14) font:[UIFont systemFontOfSize: 14] bkColor:[UIColor whiteColor] textColor:[UIColor colorWithHexString:@"818C9E"]];
        titleLabel.text = array[section - 5];
        [bavkView addSubview:titleLabel];
        [view addSubview:bavkView];
        UIView *lineView = [NSHelper createrViewFrame:CGRectMake(0, 45.5, WIDTH, 0.5) backColor:@"D9D9D9"];
        [bavkView addSubview:lineView];
        if (section == 8) {
            UIView *askView = [NSHelper createrViewFrame:CGRectMake(0, 51, WIDTH, 66) backColor:@"FFFFFF"];
            [view addSubview:askView];
            UIImageView *askimageView = [UIImageView drawImageViewLine:CGRectMake(16, 16, 34, 34) bgColor:[UIColor whiteColor]];
            askimageView.layer.masksToBounds = YES;
            askimageView.layer.cornerRadius = askimageView.frame.size.width/2.0;
            [askimageView sd_setImageWithURL:[NSURL URLWithString:[DataModelInstance shareInstance].userModel.image] placeholderImage:KHeadImageDefaultName([DataModelInstance shareInstance].userModel.realname)];
            [askView addSubview:askimageView];
            UILabel *askLabel = [UILabel createLabel:CGRectMake(56, 18, WIDTH - 56 - 16, 30) font:[UIFont systemFontOfSize:14] bkColor:[UIColor colorWithHexString:@"F8F8FA"] textColor:[UIColor colorWithHexString:@"AFB6C1"]];
            askLabel.layer.masksToBounds = YES;
            askLabel.layer.cornerRadius = 16;
            askLabel.layer.borderWidth = 0.5;
            askLabel.layer.borderColor = [UIColor colorWithHexString:@"D9D9D9"].CGColor;
            askLabel.text = @"  我要提问";
            [askView addSubview:askLabel];
            UITapGestureRecognizer *askTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(askAboutActivity:)];
            askLabel.userInteractionEnabled = YES;
            [askLabel addGestureRecognizer:askTap];
        }
    }
    return view;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat){
        static NSString *cellID = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([NONetWorkTableViewCell class])];
        }
        return cell;
    }else{
        //活动标题
        if (indexPath.section == 0) {
            static NSString *cellID = @"TitleViewCell";
            TitleViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [CommonMethod getViewFromNib:NSStringFromClass([TitleViewCell class])];
            }
            cell.titleViewCellDelegate = self;
            [cell tranferTitleViewCellModel:self.activityModel];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }else if (indexPath.section == 1) {
            //活动报道
            static NSString *cellID = @"ActivityApplyCell";
            ActifityReportCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [CommonMethod getViewFromNib:NSStringFromClass([ActifityReportCell class])];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell tranferActifityReportCellModel:self.activityModel];
            return cell;
        }else if (indexPath.section == 2) {
            //活动地址
            static NSString *cellID = @"ActivityAAddressCellddCell";
            AddressCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [CommonMethod getViewFromNib:NSStringFromClass([AddressCell class])];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell tranferAddressCellModel:self.activityModel];
            return cell;
        }else if (indexPath.section == 3) {
            //活动地址
            static NSString *cellID = @"ActivityAddCell";
            ActivityAddCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [CommonMethod getViewFromNib:NSStringFromClass([ActivityAddCell class])];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell  tranferActivityAddCellModel:self.activityModel useModel:self.userModel];
            return cell;
        }else if (indexPath.section == 4) {
            //活动报名
            static NSString *cellID = @"ActivityAddCell";
            ActivityApplyCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [CommonMethod getViewFromNib:NSStringFromClass([ActivityApplyCell class])];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [cell  traferActivityApplyCellModel:self.activityModel array:self.applyArray];
            return cell;
        }else if (indexPath.section == 5) {
            //活动介绍
            static NSString *cellID = @"IntroduceActivityCell";
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
            [cell.contentView addSubview:self.webView];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }else if (indexPath.section == 6) {
            static NSString *cellID = @"ActivityGuestsCell";
            ActivityGuestsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [CommonMethod getViewFromNib:NSStringFromClass([ActivityGuestsCell class])];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.array = self.guestArray;
            cell.index = indexPath.row;
            if(self.guestArray.count > indexPath.row){
                UserModel *model = self.guestArray[indexPath.row];
                [cell tranferActivityGuestsCellModel:model];
            }
            return cell;
        }else if (indexPath.section == 7) {
            //场地介绍
            static NSString *cellID = @"IntroduceActivityCell";
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
            [cell.contentView addSubview:self.addressImageView];
            return cell;
        }else{
            static NSString *cellID = @"ActivityAskCell";
            ActivityAskCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [CommonMethod getViewFromNib:NSStringFromClass([ActivityAskCell class])];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            if(self.askArray.count > indexPath.row){
                UserModel *model = self.askArray[indexPath.row];
                [cell tranferActivityAskCellModel:model];
            }
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _isPresentVC = YES;
    if (indexPath.section == 1) {
        InformationDetailController *activity = [[InformationDetailController alloc]init];
        activity.postID = self.activityModel.postid;
        activity.startType = YES;
        [self.navigationController pushViewController:activity animated:YES];
    }else if (indexPath.section == 2) {
        LocationMapController *myHome = [[LocationMapController alloc]init];
        myHome.latitude = self.activityModel.lat.floatValue;
        myHome.longitude = self.activityModel.lng.floatValue;
        myHome.addressStr = [NSString stringWithFormat:@"%@%@%@",self.activityModel.cityname,self.activityModel.districtname,self.activityModel.address];
        [self.navigationController pushViewController:myHome animated:YES];
    }else if (indexPath.section == 4) {
        ApplyActivityController *applyActivity = [[ApplyActivityController alloc]init];
        applyActivity.activityID = self.activityid;
        [self.navigationController pushViewController:applyActivity animated:YES];
    }else if (indexPath.section == 7) {
        WebViewController *deta = [[WebViewController alloc]init];
        deta.customTitle = @"泛合金融咖啡";
        deta.webUrl = self.activityModel.placeurl;
        [self.navigationController pushViewController:deta animated:YES];
    }
}

#pragma mark ------- 去提问
- (void)askAboutActivity:(UITapGestureRecognizer *)g{
    _isPresentVC = YES;
    MyAskAboutActivity *ask = [[MyAskAboutActivity alloc]init];
    ask.myAskAboutActivityDelegate = self;
    ask.activityid = self.activityid;
    [self presentViewController:ask animated:YES completion:nil];
}
#pragma mark ----myAskAboutActivityDelegate
- (void)referAskView{
    [self.tableView.mj_footer resetNoMoreData];
    self.activityModel.asknum = @(self.activityModel.asknum.integerValue + 1);
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:8];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    self.page = 1;
    [self getAskActivityDetailData:1];
}

#pragma mark -------- 导航颜色变化
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat titleHeigth = [NSHelper heightOfString:self.activityModel.name font:[UIFont boldSystemFontOfSize:24] width:WIDTH - 32];
    CGFloat offHeight = WIDTH*9/16;
    CGFloat heigth = scrollView.contentOffset.y;
    CGFloat alpha = heigth/(offHeight-64+titleHeigth);
    self.titleTabBaeLabel.hidden = NO;
    self.titleTabBaeLabel.alpha = alpha-0.1;
    self.tabBarView.alpha = alpha;
    if (heigth < offHeight-64+titleHeigth){
        [self.backBtn setImage:[UIImage imageNamed:@"btn_tab_back_normal"] forState:UIControlStateNormal];
        [self.recommendBtn setImage:[UIImage imageNamed:@"btn_tab_more_normal"] forState:UIControlStateNormal];
        alpha = 1.2 - alpha;
        self.backBtn.alpha = alpha;
        self.recommendBtn.alpha = alpha;
    }else{
        //  alpha = alpha*2-0.8;
        self.backBtn.alpha = alpha;
        self.recommendBtn.alpha = alpha;
        [self.backBtn setImage:[UIImage imageNamed:@"btn_tab_back"] forState:UIControlStateNormal];
        [self.recommendBtn setImage:[UIImage imageNamed:@"btn_tab_more"] forState:UIControlStateNormal];
    }
    if (heigth > (offHeight -64+titleHeigth)) {
        self.titleTabBaeLabel.text = self.activityModel.name;
    }else{
        self.titleTabBaeLabel.text = @"活动详情";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ----------//UIWebview代理
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSMutableArray *array = [NSMutableArray new];
    NSString *requestString = [[request URL] absoluteString];
    
    if ([requestString hasPrefix:@"myweb:imageClick:"]) {
        NSString *str = [requestString substringFromIndex:17];
        array = (NSMutableArray *)[str componentsSeparatedByString:@"+"];
        [self tapPhoneAction:array];
        return NO;
    }
    return YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    if (webView.isLoading) {
        return;
    }
    NSString *js = @"function imgAutoFit() { \
    var imgs = document.getElementsByTagName('img'); \
    for (var i = 0; i < imgs.length; ++i) {\
    var img = imgs[i];   \
    img.style.maxWidth = %f;   \
    } \
    }";
    js = [NSString stringWithFormat:js, [UIScreen mainScreen].bounds.size.width];
    
    [webView stringByEvaluatingJavaScriptFromString:js];
    [webView stringByEvaluatingJavaScriptFromString:@"imgAutoFit()"];
    CGFloat height = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
    
    height = ceil(height) + 10;
    CGRect frame = webView.frame;
    webView.frame = CGRectMake(16, frame.origin.y, WIDTH - 32, height );
    //js方法遍历图片添加点击事件 返回图片个数
    static  NSString * const jsGetImages =
    @"function getImages(){\
    var objs = document.getElementsByTagName(\"img\");\
    for(var i=0;i<objs.length;i++){\
    objs[i].onclick=function(){\
    var str = this.src;\
    for(var j=0;j<objs.length;j++){\
    str +=\"+\"+objs[j].src\
    }\
    document.location=\"myweb:imageClick:\"+str;\
    };\
    };\
    return objs.length;\
    };";
    
    [webView stringByEvaluatingJavaScriptFromString:jsGetImages];//注入js方法
    //注入自定义的js方法后别忘了调用 否则不会生效（不调用也一样生效了，，，不明白）
    [webView stringByEvaluatingJavaScriptFromString:@"getImages()"];
    self.heigth = self.webView.frame.size.height +16;
    //一个cell刷新
    [self.tableView reloadData];
}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.imageArray.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.imageArray.count)
        return [self.imageArray objectAtIndex:index];
    return nil;
}
- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 点击看大图
- (void)tapPhoneAction:(NSMutableArray *)array{
    NSString *selectImageURl = array[0];
    [array removeObjectAtIndex:0];
    NSInteger index = [array indexOfObject:selectImageURl];
    // Create browser
    self.imageArray = [NSMutableArray new];
    
    for (NSInteger i =0; i < array.count; i++){
        MWPhoto *po = [MWPhoto photoWithURL:[NSURL URLWithString:array[i]]];
        [self.imageArray addObject:po];
    }
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES;
    browser.displayNavArrows = YES;
    browser.displaySelectionButtons = NO;
    browser.alwaysShowControls = NO;
    //        _photoBrowser.wantsFullScreenLayout = YES;
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = NO;
    browser.startOnGrid = NO;
    [browser setCurrentPhotoIndex:index];
    [self.navigationController pushViewController:browser animated:YES];
}
- (IBAction)shareActivityAction:(UIButton *)sender {
    [self sharViewActivity];
}
- (void)sharViewActivity{
    DynamicShareView *shareView = [[DynamicShareView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    [[UIApplication sharedApplication].keyWindow addSubview:shareView];
    [shareView showOrHideView:YES];
    __weak typeof(self) shareSlef = self;
    [shareView setDynamicShareViewIndex:^(NSInteger index) {
        //转发
        if (index == 0){
            TransmitDynamicController *jinmai = [[TransmitDynamicController alloc]init];
            DynamicModel *model = [[DynamicModel alloc]init];
            model.activity_id = shareSlef.activityid;
            model.activity_image = shareSlef.activityModel.image;
            model.activity_title = shareSlef.activityModel.name;
            model.activity_timestr = shareSlef.activityModel.timestr;
            jinmai.model = model;
            [shareSlef presentViewController:jinmai animated:YES completion:nil];
        }else{
            [self firendClick:index - 1];
        }
    }];
    
}
- (IBAction)shareTapView:(UITapGestureRecognizer *)sender {
    //诸葛监控
    [[AppDelegate shareInstance] setZhugeTrack:@"浏览活动" properties:@{@"postID":[CommonMethod paramNumberIsNull:self.activityid], @"activityName":[CommonMethod paramStringIsNull:self.activityModel.name] ,@"tag": [[CommonMethod paramArrayIsNull:self.activityModel.tags]  componentsJoinedByString:@","]}];
    [self sharViewActivity];
}

#pragma mark ----------分享 ---
- (void)firendClick:(NSInteger )index{
    NSString *html = self.activityModel.subcontent;
    NSString *title = self.activityModel.name;;
    
    NSString *content = html.length>100?[html substringToIndex:100]:html;
    NSString *imageUrl = self.activityModel.image;
    NSString *contentUrl = [NSString stringWithFormat:@"%@%@",ShareActivityPageURL, self.activityid];
    UIImage *imageSource;
    if(imageUrl && imageUrl.length){
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        imageSource = [UIImage imageWithData:data];
        
    }else{
        imageSource = kImageWithName(@"icon-60");
    }
    switch (index){
        case 0:{
            [self shareUMengWeiXInTitle:title count:content url:contentUrl image:imageSource index:index];
            break;
        }
        case 1:{
            [self shareUMengWeiXInTitle:title count:content url:contentUrl image:imageSource index:index];
            break;
        }
        case 2:{
            _isPresentVC = YES;
            ChoiceFriendViewController *choseCtr = [CommonMethod getVCFromNib:[ChoiceFriendViewController class]];
            choseCtr.actModel = self.activityModel;
            [self.navigationController pushViewController:choseCtr animated:YES];
            return;
        }
        case 3:{
            [MBProgressHUD showSuccess:@"复制成功" toView:nil];
            UIPasteboard *generalPasteBoard = [UIPasteboard generalPasteboard];
            [generalPasteBoard setString:contentUrl];
            return;
        }
    }
}
- (void)shareUMengWeiXInTitle:(NSString *)title count:(NSString *)count url:(NSString *)url image:(UIImage *)imageSource index:(NSInteger)index{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    UMSocialPlatformType shareType;
    if (index == 0) {
        shareType = UMSocialPlatformType_WechatSession;
    } else{
        shareType = UMSocialPlatformType_WechatTimeLine;
    }
    //创建网页内容对象
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:count thumImage:imageSource];
    //设置网页地址
    shareObject.webpageUrl = url;
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:shareType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
    }];
}

#pragma mark ----- 报名
- (IBAction)gotoApplyActivityAction:(UIButton *)sender {
    //诸葛监控
    [[AppDelegate shareInstance] setZhugeTrack:@"浏览活动" properties:@{@"postID":[CommonMethod paramNumberIsNull:self.activityid], @"activityName":[CommonMethod paramStringIsNull:self.activityModel.name] ,@"tag":[[CommonMethod paramArrayIsNull:self.activityModel.tags]  componentsJoinedByString:@","]}];
    
    if (self.activityModel.status.integerValue == 6){
        VideoUrlController *viedeo = [[VideoUrlController alloc]init];
        viedeo.videoUrl = self.activityModel.livebroadcast_url;
        [self.navigationController pushViewController:viedeo animated:YES];
        
    }else{
        if (self.tickrtArray.count == 0) {
            [self getTickerAll];
        }
        if (self.activityModel.online_info.length > 0) {
            WebViewController *deta = [[WebViewController alloc]init];
            deta.customTitle = @"报名";
            deta.webUrl = self.activityModel.online_info;
            [self.navigationController pushViewController:deta animated:YES];
        }else if ([DataModelInstance shareInstance].userModel.hasValidUser.integerValue == 1) {
            _isPresentVC = YES;
            TicketListViewController *vc = [CommonMethod getVCFromNib:[TicketListViewController class]];
            vc.activityModel = self.activityModel;
            [self.navigationController pushViewController:vc animated:YES];
//            if (self.tickrtArray.count == 1) {
//                TicketModel *model = self.tickrtArray[0];
//                TickerDetailController *tick = [[TickerDetailController alloc]init];
//                tick.model = model;
//                tick.actModel = self.activityModel;
//                [self.navigationController pushViewController:tick animated:YES];
//            }else{
//                TicketController *tick = [[TicketController alloc]init];
//                tick.tickerArray = self.tickrtArray;
//                tick.actModel = self.activityModel;
//                [self.navigationController pushViewController:tick animated:YES];
//            }
        }else{
            _isPresentVC = YES;
            TopicIdentifyViewController *vc = [CommonMethod getVCFromNib:[TopicIdentifyViewController class]];
            vc.publishType = JoinType_Action;
            [self.navigationController pushViewController:vc animated:YES];
            
        }
        
    }
}

- (void)getTickerAll{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@",self.activityid] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_ACTIVITY_TICKET_LIST paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            for (NSDictionary *dict in array) {
                TicketModel *model = [[TicketModel alloc] initWithDict:dict];
                [weakSelf.tickrtArray addObject:model];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        
    }];
}

- (void)viewIsHidder{
    _isPresentVC = YES;
}

@end
