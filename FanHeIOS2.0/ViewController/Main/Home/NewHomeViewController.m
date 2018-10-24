//
//  HomeViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/10/25.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "NewHomeViewController.h"
#import "MenuView.h"
#import "HomeTableViewCell.h"
#import "RecommendCell.h"
#import "DynamicCell.h"

#import "EditPersonalInfoViewController.h"
#import "FirstLaunchGuideView.h"
#import "NeedCompleteInfoView.h"
#import "AdvertisementView.h"

#import "MCScrollView.h"
#import "CoffeeIntroduceViewController.h"
#import "DetaileViewController.h"
#import "InformationDetailController.h"
#import "PosterWebViewController.h"
#import "ActivityDetailController.h"
#import "TopicViewController.h"

#import "SearchViewController.h"

#import "CreateDynamicController.h"
#import "CreateTopicViewController.h"
#import "TopicIdentifyViewController.h"
#import "CreateActivityViewController.h"
#import "VariousDetailController.h"
#import "DynamicNotificationCtr.h"

#import "MyDynamicListController.h"
#import "NONetWorkTableViewCell.h"
#import "LiveVideoView.h"
#import "ChangeInformationViewGuid.h"
#import "ChoiceNeedSupplyController.h"
#import "NeedSupplyErrorView.h"
#import "TouTiaoRecomView.h"
#import "FriendFriendsViewController.h"
#import "TaskListViewController.h"
#import "HMCRunLoopTask.h"

#define Cell_Index_key(index) ([NSString stringWithFormat:@"cell_%ld", (long)index])

@interface NewHomeViewController ()<FirstLaunchGuideViewDelegate>{
    BOOL _isHandRefresh;
    BOOL _isUploading;
}

@property (nonatomic, strong) UIButton *remindBtn;//无网络、刷新提示

@property (nonatomic, strong) MCScrollView *bannerView;

@property (nonatomic, strong) NSMutableArray *bannerArray;

@property (nonatomic, strong) NeedCompleteInfoView *needCompleteInfoView;

@property (nonatomic, assign) NSInteger showRefreshNum;//更新了多少条
@property (nonatomic, assign) NSInteger showMessageNum;//新的通知
@property (nonatomic, assign) BOOL showLatestRefresh;//已经是最新的
@property (nonatomic, assign) BOOL showNetWork;//无网络
@property (nonatomic, assign) BOOL showDynamicUpload;//动态尚未上传

@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, strong) HomeTableDataModel *homeTableDataModel;
@property (nonatomic, strong) NSMutableArray *toutiaoArray;

@property (nonatomic, strong) MenuView *menuView;

@property (nonatomic, assign) BOOL menuShow;

@property (nonatomic, strong) MyActivityModel *myActivityModel;
@property (nonatomic, strong) LiveVideoView *liveVideoView;
@property (nonatomic, strong) NSArray *nameArray;
@property (nonatomic, strong) NSString *changeMsg;

@property (nonatomic, strong) NSNumber *lastDynamicId;

@property (nonatomic, strong) HMCRunLoopTask *runloopTask;
@end

@implementation NewHomeViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self loadHttpAdvertisementData];
    //新用户第一次进入时提示完善资料
    NSDate *editDate = [[NSUserDefaults standardUserDefaults] objectForKey:ShowCompleteUserInfoEditViewDate];
    if(![[NSUserDefaults standardUserDefaults] boolForKey:FirstLaunchGuideViewMark]){
        //第一次功能介绍引导
        [self showFirstLaunchGuideView];
    }else if(editDate == nil && [CommonMethod getUserInfoCompletionRate] == 10){
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:ShowCompleteUserInfoEditViewDate];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self needCompleteUserInfoButtonClicked];
    }else{
        if(self.needCompleteInfoView){
            [self.needCompleteInfoView updateDisplay];
        }
    }
    //更新群组成员信息
    [self updateAllGroupUsersDB];
    [self.runloopTask startTimer];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.runloopTask endTimer];
}

- (void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVCDisplay) name:@"topage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView:) name:@"reloadTableView" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(netWorkChange:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveDynamicData) name:UIApplicationWillTerminateNotification object:nil];
    
    if([DataModelInstance shareInstance].userModel.noUploadDynamicData.count==0){
        [self cleanFolder];
    }
   
//    [self getVersionHttpData];
    [self createNavBarButtonItems];
    __weak typeof(self) weakSelf = self;
    self.leftButtonClicked = ^(){
        if(weakSelf.menuShow){
            weakSelf.menuShow = NO;
            [weakSelf.menuView showMenuWithAnimation:weakSelf.menuShow];
            weakSelf.menuView = nil;
        }
    };
    self.dynamicRequestBlock = ^(NSNumber *number){
        if(weakSelf.showMessageNum != number.integerValue){
            weakSelf.showMessageNum = number.integerValue;
            [weakSelf initTableViewHeaderView];
            [[AppDelegate shareInstance] showUnreadCountViewItemNO:0 unReadCountSum:weakSelf.showMessageNum];
        }
    };
    [[AppDelegate shareInstance] setZhugeTrack:@"进入首页" properties:@{}];
    
    //完成开启通知任务调接口
    [self finishOpenNotification];
}

#pragma mark -完成开启通知任务调接口
- (void)finishOpenNotification{
    UIUserNotificationType type = [[UIApplication sharedApplication] currentUserNotificationSettings].types;
    BOOL isOpenNoti = (type!=UIUserNotificationTypeNone);
    if(isOpenNoti){
        NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
        [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
        [requestDict setObject:@(13) forKey:@"taskid"];
        [self requstType:RequestType_Post apiName:API_NAME_POST_TASK_COMPLETETASK paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        }];
    }
}

#pragma mark - 缓存首页数据
- (void)saveDynamicData{
    NSMutableArray *dataArray = [NSMutableArray array];
    for(int i = 0; i < self.listArray.count; i++){
        if([self.listArray[i] isKindOfClass:[DynamicModel class]]){
            DynamicModel *model = self.listArray[i];
            if(model.dynamic_id.integerValue<0){
                continue;
            }
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[model properties_aps]];
            for(NSString *key in @[@"cellHeight",@"contentHeight",@"imageHeight",@"shareViewHeight",@"shareNameHeight",@"shareContentHeight",@"shareSubViewHeight",@"shareViewOnlyHeight",@"commentRows",@"commentContentRows",@"commentHeight",@"shareSubViewTitle",@"uploadFailure",@"isDynamicDetail",@"isTaDynamicList",@"cellTag",@"enabledHeaderBtnClicked", @"userModel", @"dynamic_reviewlist", @"needTitleHeight", @"needContentHeight"]){
                [dict removeObjectForKey:key];
            }
            NSMutableArray *commentArray = [NSMutableArray array];
            for(DynamicCommentModel *commentModel in model.dynamic_reviewlist){
                NSMutableDictionary *commentDict = [NSMutableDictionary dictionaryWithDictionary:[commentModel properties_aps]];
                for(NSString *key in @[@"showContent",@"senderModel",@"replytoModel"]){
                    [commentDict removeObjectForKey:key];
                }
                [commentDict addEntriesFromDictionary:[commentModel.senderModel properties_aps]];
                [commentDict setObject:[CommonMethod paramDictIsNull:[commentModel.replytoModel properties_aps]] forKey:@"replyto"];
                [commentArray addObject:commentDict];
            }
            [dict setObject:commentArray forKey:@"dynamic_reviewlist"];
            [dict addEntriesFromDictionary:[model.userModel properties_aps]];
            [dataArray addObject:dict];
        }else{
            HomeRCMModel *model = self.listArray[i];
            NSDictionary *dict = [model properties_aps];
            [dataArray addObject:dict];
        }
    }
    UserModel *userModel = [DataModelInstance shareInstance].userModel;
    userModel.dynamicData = dataArray;
    [DataModelInstance shareInstance].userModel = userModel;
}

- (void)reloadTableView:(NSNotification *)notification{
    NSNumber *index = (NSNumber*)notification.object;
    if(index.integerValue>=0){
        for(NSIndexPath *indexPath in [self.tableView indexPathsForVisibleRows]){
            if(indexPath.row == index.integerValue){
                [self.tableView reloadData];
                //[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
    }
}

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

#pragma mark － 完善资料
- (void)needCompleteUserInfoButtonClicked{
    CompleteUserInfoView *completeUserInfoView = [[CompleteUserInfoView alloc] initWithType:CompleteUserInfoViewType_FirstLogin];
    completeUserInfoView.completeUserInfoViewEditInfo = ^(){
        EditPersonalInfoViewController *vc = [[EditPersonalInfoViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    };
    completeUserInfoView.completeUserInfoViewCancle = ^(){
        if(self.needCompleteInfoView){
            [self.needCompleteInfoView updateDisplay];
        }
    };
}

#pragma mark - 首页功能引导页
- (void)showFirstLaunchGuideView{
    FirstLaunchGuideView *view = [CommonMethod getViewFromNib:@"FirstLaunchGuideView"];
    view.viewType = FLGV_Type_HomeVC;
    view.firstLaunchGuideViewDelegate = self;
    [view newUserGuide];
    view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
}

#pragma mark -FirstLaunchGuideViewDelegate
- (void)mainFeistMoveMark:(NSInteger)index{
    //新用户第一次进入时提示完善资料
    NSDate *editDate = [[NSUserDefaults standardUserDefaults] objectForKey:ShowCompleteUserInfoEditViewDate];
    if(editDate == nil && [CommonMethod getUserInfoCompletionRate] == 10){
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:ShowCompleteUserInfoEditViewDate];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self needCompleteUserInfoButtonClicked];
    }else{
        if(self.needCompleteInfoView){
            [self.needCompleteInfoView updateDisplay];
        }
    }
}

//导航栏右边按钮
- (void)createNavBarButtonItems{
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(0, 0, 30, 40);
    [searchBtn setImage:kImageWithName(@"btn_search_white") forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(gotoSearchButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    
    UIButton *publishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    publishBtn.frame = CGRectMake(0, 0, 30, 40);
    [publishBtn setImage:kImageWithName(@"btn_fb_add") forState:UIControlStateNormal];
    [publishBtn addTarget:self action:@selector(gotoPublishButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *publishButtonItem = [[UIBarButtonItem alloc] initWithCustomView:publishBtn];
    
    self.navigationItem.rightBarButtonItems =@[publishButtonItem, searchButtonItem];
}

//进入App弹出的广告
- (void)showAdvertisement{
    if([[NSUserDefaults standardUserDefaults] boolForKey:FirstLaunchGuideViewMark]){
        AdvertisementView *view = [CommonMethod getViewFromNib:@"AdvertisementView"];
        view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    }
}

//预加载
- (void)updateVCDisplay{
    self.lastDynamicId = @(0);
    self.bannerArray = [NSMutableArray array];
    self.listArray = [NSMutableArray array];
    self.toutiaoArray = [NSMutableArray array];
    
    self.nameArray = [NSArray new];
    [self getChangeIformation];
    [self loadLiveVideoData];
    
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64-49)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.tableView.showsVerticalScrollIndicator = NO;
    [self.tableView tableViewAddDownLoadRefreshing:^{
        [self.tableView.mj_footer resetNoMoreData];
        [self getChangeIformation];
        [self loadHttpNewHomeData:YES];
        [self loadHttpRCMListData];
        [self loadHttpHomeData];
    }];
    [self.tableView tableViewAddUpLoadRefreshing:^{
        [self loadHttpNewHomeData:NO];
    }];
    
    UserModel *userModel = [DataModelInstance shareInstance].userModel;
    if(userModel.homeData.allKeys.count || userModel.dynamicData.count || userModel.rcmListData.count){
        HomeDataModel *homeDataModel = [[HomeDataModel alloc] initWithDict:[CommonMethod paramDictIsNull:userModel.homeData]];
        if(homeDataModel.mayknowpeople.count){
            self.homeTableDataModel = [[HomeTableDataModel alloc] init];
            self.homeTableDataModel.type = @(1);
            self.homeTableDataModel.title = @"人脉推荐";
            self.homeTableDataModel.array = homeDataModel.mayknowpeople;
        }
        for(NSDictionary *dict in [CommonMethod paramArrayIsNull:userModel.rcmListData]){
            BannerModel *model = [[BannerModel alloc] initWithDict:dict];
            [self.bannerArray addObject:model];
        }
        NSInteger cellTag = 0;
        for(NSDictionary *dict in userModel.dynamicData){
            if(([CommonMethod paramNumberIsNull:dict[@"type"]].integerValue >= 14 && [CommonMethod paramNumberIsNull:dict[@"type"]].integerValue < 17) || [CommonMethod paramNumberIsNull:dict[@"type"]].integerValue > 17){
                HomeRCMModel *rcmModel = [[HomeRCMModel alloc] initWithDict:dict];
                [self.listArray addObject:rcmModel];
            }else{
                DynamicModel *dynamicModel = [[DynamicModel alloc] initWithDict:dict cellTag:cellTag];
                [self.listArray addObject:dynamicModel];
            }
            cellTag++;
        }
        cellTag = 0;
        for(NSDictionary *dict in userModel.noUploadDynamicData){
            DynamicModel *dynamicModel = [[DynamicModel alloc] initWithDict:dict cellTag:cellTag];
            [self.listArray insertObject:dynamicModel atIndex:0];
            cellTag++;
        }
        [self initTableViewHeaderView];
        [self.tableView reloadData];
        [self.tableView.mj_header beginRefreshing];
    }else{
        [self initTableViewHeaderView];
        [self loadHttpNewHomeData:NO];
        [self loadHttpRCMListData];
        [self loadHttpHomeData];
    }
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(WIDTH-78 , HEIGHT-127, 54, 54);
    [btn setBackgroundImage:kImageWithName(@"btn_index_add") forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(gotoSupplyNeedAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    self.runloopTask = [[HMCRunLoopTask alloc] init];
    [self.runloopTask startTimer];
}

#pragma mark ----- 发布需求
- (void)gotoSupplyNeedAction:(UIButton*)sender{
    sender.userInteractionEnabled = NO;
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[NSString stringWithFormat:@"/%@",[DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_USER_RESTGX paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        sender.userInteractionEnabled = YES;
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            NSDictionary *dic = [CommonMethod paramDictIsNull:responseObject[@"data"]];
            NSNumber *rest_times = [CommonMethod paramNumberIsNull:dic[@"rest_times"]];
            if (rest_times.integerValue > 0) {
                ChoiceNeedSupplyController *vc = [[ChoiceNeedSupplyController alloc]init];
                vc.limit_times_cn = [CommonMethod paramStringIsNull:dic[@"limit_times_cn"]];
                vc.publishNeedSupplySuccess = ^(BOOL isNeed) {
                    [weakSelf loadHttpNewHomeData:YES];
                };
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }else{
                NeedSupplyErrorView *view = [CommonMethod getViewFromNib:@"NeedSupplyErrorView"];
                view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
                view.limit_times_cn = [CommonMethod paramStringIsNull:dic[@"limit_times_cn"]];
                view.confirmButtonClicked = ^{
                    ChoiceNeedSupplyController *vc = [[ChoiceNeedSupplyController alloc]init];
                    vc.limit_times_cn = [CommonMethod paramStringIsNull:dic[@"limit_times_cn"]];
                    vc.publishNeedSupplySuccess = ^(BOOL isNeed) {
                        [weakSelf loadHttpNewHomeData:YES];
                    };
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                };
                [[UIApplication sharedApplication].keyWindow addSubview:view];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        sender.userInteractionEnabled = YES;
    }];
}

#pragma mark - 网络变化
- (void)netWorkChange:(NSNotification *)netWorkChange{
    Reachability *reach = [netWorkChange object];
    if(_showNetWork != (reach.currentReachabilityStatus==NotReachable)){
        _showNetWork = reach.currentReachabilityStatus==NotReachable;
        [self showNetWorkStatue];
        if([DataModelInstance shareInstance].userModel.noUploadDynamicData.count && _showNetWork==NO){
            [self uploadDynamicData];
        }
    }
}

- (void)showNetWorkStatue{
    //无网络提示、刷新提示
    if(_showRefreshNum || _showNetWork || _showLatestRefresh){
        NSString *textColor = @"3c99da";
        NSString *bgColor = @"d5e9f7";
        NSString *textStr;
        if(_showRefreshNum){
            textStr = [NSString stringWithFormat:@"更新了%@条动态", @(_showRefreshNum)];
            _showRefreshNum = 0;
        }else if(_showLatestRefresh){
            textStr = @"休息一会儿吧，已经是最新动态了";
            _showLatestRefresh = NO;
        }else{
            bgColor = @"ffe1e1";
            textColor = @"8b4542";
            textStr = @"没有网络连接，请检查网络设置";
        }
        if (self.remindBtn==nil) {
            [self.tableView.mj_header removeFromSuperview];
            self.tableView.mj_header = nil;
//            CGFloat offset_Y = self.tableView.contentOffset.y;
            CGFloat content_Top = self.tableView.contentInset.top;
            self.tableView.contentInset = UIEdgeInsetsMake(content_Top+36, 0, 0, 0);
            [self.tableView setContentOffset:CGPointMake(0, -36)];//offset_Y
            self.remindBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.remindBtn.frame = CGRectMake(0, -36, WIDTH, 36);
            [self.remindBtn setTitle:textStr forState:UIControlStateNormal];
            [self.remindBtn setTitleColor:HEX_COLOR(textColor) forState:UIControlStateNormal];
            self.remindBtn.titleLabel.font = [UIFont systemFontOfSize:14];
            self.remindBtn.backgroundColor = HEX_COLOR(bgColor);
            [self.tableView addSubview:self.remindBtn];
        }
        if(!_showRefreshNum || !_showLatestRefresh){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showNetWorkStatue];
            });
        }
    }else{
        if(self.remindBtn){
            [UIView animateWithDuration:.5 animations:^{
                self.remindBtn.alpha = 0.5;
                [self.tableView setContentOffset:CGPointMake(0, 0)];
                self.tableView.contentInset = UIEdgeInsetsZero;
            }completion:^(BOOL finished) {
                [self.remindBtn removeFromSuperview];
                self.remindBtn = nil;
            }];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.tableView tableViewAddDownLoadRefreshing:^{
                    [self.tableView.mj_footer resetNoMoreData];
                    [self getChangeIformation];
                    [self loadLiveVideoData];
                    [self loadHttpAdvertisementData];
                    [self loadHttpNewHomeData:YES];
                    [self loadHttpRCMListData];
                    [self loadHttpHomeData];
                }];
                if(self.listArray.count==0){
                    [self loadHttpNewHomeData:NO];
                }
                if(self.bannerArray.count==0){
                    [self loadHttpRCMListData];
                }
                if(self.homeTableDataModel==nil){
                    [self loadHttpHomeData];
                }
            });
            
        }
    }
}

#pragma mark ------- 去搜索
- (void)gotoSearchButtonClicked:(UIButton*)sender{
    if(_menuShow){
        _menuShow = NO;
        [self.menuView showMenuWithAnimation:_menuShow];
        self.menuView = nil;
    }
    SearchViewController *vc = [CommonMethod getVCFromNib:[SearchViewController class]];
    vc.isFrist = YES;
    vc.view.transform = CGAffineTransformMakeTranslation(0, 64);
    vc.view.alpha = 0.8;
    [UIView animateWithDuration:0.3 animations:^{
        vc.view.alpha = 1;
        vc.view.transform = CGAffineTransformMakeTranslation(0, 0);
    }];
    [self.navigationController pushViewController:vc animated:NO];
}

#pragma mark ------- 发布
- (void)gotoPublishButtonClicked:(UIButton*)sender{
    _menuShow = !_menuShow;
    [self.menuView showMenuWithAnimation:_menuShow];
    if(_menuShow==NO){
        self.menuView = nil;
    }
}

//创建动态
- (void)createDynamic{
    if([DataModelInstance shareInstance].userModel.hasValidUser.integerValue==1 || [DataModelInstance shareInstance].userModel.hasPublishDynamic.integerValue!=1){
        CreateDynamicController *vc = [CommonMethod getVCFromNib:[CreateDynamicController class]];
        vc.createDynamicSuccess = ^(DynamicModel *model){
            [self.listArray insertObject:model atIndex:0];
            [self.tableView reloadData];
            
            [self uploadDynamicData];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        TopicIdentifyViewController *vc = [CommonMethod getVCFromNib:[TopicIdentifyViewController class]];
        vc.publishType = PublishType_Dynamic;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//创建话题
- (void)createTopic{
    if([DataModelInstance shareInstance].userModel.hasValidUser.integerValue == 1){
        CreateTopicViewController *vc = [[CreateTopicViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        TopicIdentifyViewController *vc = [CommonMethod getVCFromNib:[TopicIdentifyViewController class]];
        vc.publishType = PublishType_Topic;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//发布活动
- (void)createActivity{
    if([DataModelInstance shareInstance].userModel.hasValidUser.integerValue == 1){
        CreateActivityViewController *vc = [CommonMethod getVCFromNib:[CreateActivityViewController class]];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        TopicIdentifyViewController *vc = [CommonMethod getVCFromNib:[TopicIdentifyViewController class]];
        vc.publishType = PublishType_Activity;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//弹出下拉菜单
- (MenuView *)menuView{
    if (!_menuView) {
        NSArray *dataArray = @[@{@"itemName" : @"发布工作动态", @"imageName":@"icon_trends_as"},@{@"itemName" : @"发起金融话题", @"imageName":@"icon_topic_as"},@{@"itemName" : @"发布行业活动", @"imageName":@"icon_event_as"},@{@"itemName" : @"扫一扫", @"imageName":@"icon_scan_as"}];
        
        __weak typeof(self)weakSelf = self;
        _menuView = [MenuView createMenuWithFrame:CGRectMake(0, 0, 150, dataArray.count * 40) target:self dataArray:dataArray itemsClickBlock:^(NSString *str, NSInteger tag) {
            if(tag==0){
                [weakSelf createDynamic];
            }else if(tag==1){
                [weakSelf createTopic];
            }else if(tag==2){
                [weakSelf createActivity];
            }else if(tag==3){
                [weakSelf scanQRCode];
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

#pragma mark--表头，消息提示
- (void)initTableViewHeaderView{
    UIView *headerView = [self.tableView viewWithTag:2000];
    if(headerView == nil){
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, -90, WIDTH, 90)];
        headerView.backgroundColor = kBackgroundColorDefault;
        headerView.tag = 2000;
        [self.tableView addSubview:headerView];
    }else{
        for(UIView *view in headerView.subviews){
            [view removeFromSuperview];
        }
    }
    headerView.backgroundColor = kTableViewBgColor;
    
    CGFloat start_Y = 0;
    
    if(_showDynamicUpload != ([DataModelInstance shareInstance].userModel.noUploadDynamicData.count>0) && _isHandRefresh==NO){
        _showDynamicUpload = [DataModelInstance shareInstance].userModel.noUploadDynamicData.count>0;
    }
    _isHandRefresh = NO;
    //还有动态未上传成功
    if(_showDynamicUpload){
        UILabel *dynamicView = [UILabel createrLabelframe:CGRectMake(0, 0, WIDTH, 35) backColor:HEX_COLOR(@"dfe1e7") textColor:KTextColor test:@"动态发送失败，点击重新发送\t" font:14 number:1 nstextLocat:NSTextAlignmentCenter];
        [headerView addSubview:dynamicView];
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH/2+90, 12, 10, 10)];
        iconImageView.image = kImageWithName(@"icon_jt_shuang");
        [headerView addSubview:iconImageView];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, WIDTH, 35);
        [btn setBackgroundImage:kImageWithColor([BLACK_COLOR colorWithAlphaComponent:0.5],CGRectMake(0, 0, WIDTH, 35)) forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(againUploadDynamic:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:btn];
        start_Y += 35;
    }
    
    //有新的通知
    if(_showMessageNum){
        UIView *messageView = [[UIView alloc] initWithFrame:CGRectMake((WIDTH-126)/2, start_Y+14, 120, 26)];
        messageView.backgroundColor = HEX_COLOR(@"41464e");
        messageView.layer.masksToBounds = YES;
        messageView.layer.cornerRadius = 4;
        [headerView addSubview:messageView];
        [CommonMethod viewAddGuestureRecognizer:messageView tapsNumber:1 withTarget:self withSEL:@selector(gotoNoticeVC)];
        
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 6, 12, 15)];
        iconImageView.image = kImageWithName(@"icon_xx_message");
        [messageView addSubview:iconImageView];
        UILabel *messageLabel = [UILabel createrLabelframe:CGRectMake(28, 0, 92, 26) backColor:[UIColor clearColor] textColor:HEX_COLOR(@"e6e8eb") test:[NSString stringWithFormat:@"%@ 条新通知", @(_showMessageNum)] font:14 number:1 nstextLocat:NSTextAlignmentLeft];
        [messageView addSubview:messageLabel];
        UIImageView *nextImageView = [[UIImageView alloc] initWithFrame:CGRectMake(106, 8, 5, 10)];
        nextImageView.image = kImageWithName(@"icon_xx_jt");
        [messageView addSubview:nextImageView];
        start_Y += 54;
    }
    if(self.bannerArray.count){
        if(self.bannerView){
            [self.bannerView endTimer];
            [self.bannerView removeFromSuperview];
            self.bannerView = nil;
        }
        CGFloat bannerHeight = 140*WIDTH/375;
        self.bannerView = [[MCScrollView alloc] initWithFrame:CGRectMake(0, start_Y, WIDTH, bannerHeight) ParameterArray:self.bannerArray];
        self.bannerView.backgroundColor = [UIColor redColor];
        [self.bannerView startTimer];
        @weakify(self);
        self.bannerView.scrollViewClickIndex = ^(NSInteger index){
            @strongify(self);
            BannerModel *model = self.bannerArray[index];
            [[AppDelegate shareInstance] setZhugeTrack:@"banner点击" properties:@{@"bannerType":[CommonMethod paramNumberIsNull:model.type]}];
            //0.外链 1.资讯 2.活动 3.话题 4.场地 5.海报 6.任务列表
            if(model.type.integerValue==0){
                DetaileViewController *vc = [[DetaileViewController alloc] init];
                vc.url = model.url;
                if([[CommonMethod paramStringIsNull:model.url] length]){
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }else if(model.type.integerValue==1){
                InformationDetailController *vc = [[InformationDetailController alloc] init];
                vc.postID = [NSNumber numberWithInteger:model.url.integerValue];
                [self.navigationController pushViewController:vc animated:YES];
            }else if(model.type.integerValue==2){
                ActivityDetailController *vc = [[ActivityDetailController alloc] init];
                vc.activityid = [NSNumber numberWithInteger:model.url.integerValue];
                [self.navigationController pushViewController:vc animated:YES];
            }else if(model.type.integerValue==3){
                TopicViewController *vc = [[TopicViewController alloc] init];
                vc.subjectId = [NSNumber numberWithInteger:model.url.integerValue];
                [self.navigationController pushViewController:vc animated:YES];
            }else if(model.type.integerValue==4){
                [self.navigationController pushViewController:[[CoffeeIntroduceViewController alloc] init] animated:YES];
            }else if(model.type.integerValue==5){
                PosterWebViewController *vc = [CommonMethod getVCFromNib:[PosterWebViewController class]];
                [self.navigationController pushViewController:vc animated:YES];
            }else if(model.type.integerValue==6){
                TaskListViewController *vc = [[TaskListViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
        };
        [headerView addSubview:self.bannerView];
        start_Y += bannerHeight+10;
    }
    
    //金脉头条推荐
    if(self.toutiaoArray.count){
        TouTiaoRecomView *toutiaoView = [CommonMethod getViewFromNib:@"TouTiaoRecomView"];
        [toutiaoView updateDispaly:self.toutiaoArray.firstObject];
        toutiaoView.frame = CGRectMake(0, start_Y, WIDTH, 135);
        toutiaoView.backgroundColor = WHITE_COLOR;
        [headerView addSubview:toutiaoView];
        start_Y += 135;
    }
    
    //是否有直播
    if (self.myActivityModel.activityid.integerValue > 0) {
        if (self.liveVideoView) {
            [self.liveVideoView removeFromSuperview];
        }
        self.liveVideoView = [CommonMethod getViewFromNib:@"LiveVideoView"];
        self.liveVideoView.frame = CGRectMake(0, start_Y, WIDTH, 150);
        [self.liveVideoView.coverImageView sd_setImageWithURL:[NSURL URLWithString:self.myActivityModel.image] placeholderImage:KWidthImageDefault];
        self.liveVideoView.liveVideoStat.text = self.myActivityModel.timestr;
        if ([self.myActivityModel.timestr isEqualToString:@"正在直播"]) {
            self.liveVideoView.addressLabel.text = self.myActivityModel.addr;
        }else{
            self.liveVideoView.addressLabel.text = self.myActivityModel.livebroadcast_start;
        }
        self.liveVideoView.titlaLabel.text = self.myActivityModel.name;
               self.liveVideoView.videoUrl = self.myActivityModel.activityid;
        [headerView addSubview:self.liveVideoView];
        start_Y += 160;
    }
    
    __block HomeTableViewCell *recommendView;
    __block ChangeInformationViewGuid *changeView;
    __weak NeedCompleteInfoView *needCompleteInfoView = [CommonMethod getViewFromNib:@"NeedCompleteInfoView"];
    if(needCompleteInfoView.type != NeedCompleteInfoViewType_None){
        needCompleteInfoView.frame = CGRectMake(0, start_Y, WIDTH, 82);
        needCompleteInfoView.needCompleteInfoViewClicked = ^(NeedCompleteInfoViewType type){
            if(type == NeedCompleteInfoViewType_None){
                [UIView animateWithDuration:0.5 animations:^{
                    [needCompleteInfoView removeFromSuperview];
                    CGFloat height = start_Y;
                    if(self.homeTableDataModel && self.homeTableDataModel.array.count){
                        recommendView.frame = CGRectMake(0, start_Y, WIDTH, 270);
                        height += 270;
                    }
                    if(self.nameArray.count){
                        changeView.frame = CGRectMake(0, height, WIDTH, 50);
                        changeView.clickedChangeInfoViewGuid = ^{
                            headerView.frame = CGRectMake(0, 0, WIDTH, height);
                            self.tableView.tableHeaderView = headerView;
                        };
                        height += 60;
                    }
                    headerView.frame = CGRectMake(0, 0, WIDTH, height);
                    self.tableView.tableHeaderView = headerView;
                    self.needCompleteInfoView = nil;
                } completion:^(BOOL finished) {
                }];
            }
        };
       
        [headerView addSubview:needCompleteInfoView];
        start_Y += 92;
        self.needCompleteInfoView = needCompleteInfoView;
    }else{
        self.needCompleteInfoView = nil;
    }
    
    if(self.homeTableDataModel && self.homeTableDataModel.array.count){
        recommendView = [[HomeTableViewCell alloc] initWithFrame:CGRectMake(0, start_Y, WIDTH, 270)];
        recommendView.frame = CGRectMake(0, start_Y, WIDTH, 270);
        recommendView.backgroundColor = WHITE_COLOR;
        [recommendView updateDisplay:self.homeTableDataModel];
        recommendView.deleteAllUserModel = ^{
            [UIView animateWithDuration:0.5 animations:^{
                CGFloat height = start_Y;
                if(self.nameArray.count){
                    changeView.frame = CGRectMake(0, height, WIDTH, 50);
                    changeView.clickedChangeInfoViewGuid = ^{
                        headerView.frame = CGRectMake(0, 0, WIDTH, height);
                        self.tableView.tableHeaderView = headerView;
                    };
                    height += 60;
                }
                headerView.frame = CGRectMake(0, 0, WIDTH, height);
                self.tableView.tableHeaderView = headerView;
            } completion:^(BOOL finished) {
            }];
        };
        [headerView addSubview:recommendView];
        start_Y += 270;
    }
    
    if(self.nameArray.count > 0) {
        changeView = [CommonMethod getViewFromNib:@"ChangeInformationViewGuid"];
        changeView.frame = CGRectMake(0, start_Y, WIDTH, 50);
        changeView.clickedChangeInfoViewGuid = ^{
            headerView.frame = CGRectMake(0, 0, WIDTH, start_Y);
            self.tableView.tableHeaderView = headerView;
        };
        [changeView tranferString:self.changeMsg name:self.nameArray];
        [headerView addSubview:changeView];
        start_Y += 60;
    }
    
    headerView.frame = CGRectMake(0, 0, WIDTH, start_Y);
    
    self.tableView.tableHeaderView = headerView;
}

//动态发送失败，重新发送
- (void)againUploadDynamic:(UIButton*)sender{
    [self newThreadForAvoidButtonRepeatClick:sender];
    _isHandRefresh = YES;
    _showDynamicUpload = NO;
    [self initTableViewHeaderView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self uploadDynamicData];
    });
}

//点击消息通知，进入通知列表
- (void)gotoNoticeVC{
    DynamicNotificationCtr *vc = [[DynamicNotificationCtr alloc] init];
    vc.notecount = @(_showMessageNum);
    [self.navigationController pushViewController:vc animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _showMessageNum = 0;
        [self initTableViewHeaderView];
        [[AppDelegate shareInstance] showUnreadCountViewItemNO:0 unReadCountSum:0];
    });
}

#pragma mark -获取首页数据(新的接口) isRefresh
- (void)loadHttpNewHomeData:(BOOL)isRefresh{
    _showNetWork = NO;
    _showRefreshNum = 0;
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    NSNumber *firstDynamicId = @(0);
    if(self.listArray.count){
        if(isRefresh){
            if([self.listArray.firstObject isKindOfClass:[DynamicModel class]]){
                DynamicModel *model = self.listArray.firstObject;
                firstDynamicId = model.dynamic_id;
            }else{
                HomeRCMModel *model = self.listArray.firstObject;
                firstDynamicId = model.rfid;
            }
            _lastDynamicId = @(0);
        }else{
            if([self.listArray.lastObject isKindOfClass:[DynamicModel class]]){
                DynamicModel *model = self.listArray.lastObject;
                [requestDict setObject:model.type forKey:@"type"];
            }else{
                HomeRCMModel *model = self.listArray.lastObject;
                [requestDict setObject:model.type forKey:@"type"];
            }
            [requestDict setObject:_lastDynamicId forKey:@"dynamicid"];
        }
    }
    [self requstType:RequestType_Post apiName:API_NAME_POST_DYNAMIC_FEEDDYNAMIC_V4 paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:responseObject[@"data"]];
            if(array.count || isRefresh){
                [weakSelf.tableView endRefresh];
            }else{
                [weakSelf.tableView endRefreshNoData];
            }
            if(isRefresh){
                [weakSelf.listArray removeAllObjects];
                UserModel *userModel = [DataModelInstance shareInstance].userModel;
                userModel.dynamicData = array;
                [DataModelInstance shareInstance].userModel = userModel;
                
                NSInteger cellTag = 0;
                for(NSDictionary *dict in [DataModelInstance shareInstance].userModel.noUploadDynamicData){
                    DynamicModel *dynamicModel = [[DynamicModel alloc] initWithDict:dict cellTag:cellTag];
                    [self.listArray addObject:dynamicModel];
                    cellTag++;
                }
            }
            
            NSInteger cellTag = weakSelf.listArray.count;
            NSInteger newCount = 0;
            for(NSDictionary *dict in array){
                if(([CommonMethod paramNumberIsNull:dict[@"type"]].integerValue >= 14 && [CommonMethod paramNumberIsNull:dict[@"type"]].integerValue < 17) || [CommonMethod paramNumberIsNull:dict[@"type"]].integerValue > 17){
                    HomeRCMModel *rcmModel = [[HomeRCMModel alloc] initWithDict:dict];
                    [weakSelf.listArray addObject:rcmModel];
                    if(rcmModel.rfid.integerValue==firstDynamicId.integerValue&&!_showRefreshNum){
                        _showRefreshNum = newCount;
                    }
                }else{
                    DynamicModel *dynamicModel = [[DynamicModel alloc] initWithDict:dict cellTag:cellTag];
                    [weakSelf.listArray addObject:dynamicModel];
                    if(dynamicModel.dynamic_id.integerValue==firstDynamicId.integerValue&&!_showRefreshNum){
                        _showRefreshNum = newCount;
                    }
                }
                cellTag++;
                newCount++;
            }
            if(weakSelf.listArray.count){
                DynamicModel *model = weakSelf.listArray.lastObject;
                _lastDynamicId = model.dynamic_id;
            }
            [weakSelf.tableView reloadData];
            if(isRefresh){
                if(!_showRefreshNum){
                    _showLatestRefresh = YES;
                }
                [weakSelf showNetWorkStatue];
            }
        }else{
            [weakSelf.tableView endRefresh];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [weakSelf.tableView endRefresh];
        _showNetWork = YES;
        [weakSelf showNetWorkStatue];
    }];
}

#pragma mark -获取首页数据（想认识我的人 可能认识的人 人气之星 看过我的人 活动预告  大家聊金融）
- (void)loadHttpHomeData{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@", [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_USER_GET_HOME_DATA_V4 paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            HomeDataModel *homeDataModel = [[HomeDataModel alloc] initWithDict:responseObject[@"data"]];
            weakSelf.toutiaoArray = homeDataModel.tt;
            weakSelf.homeTableDataModel = [[HomeTableDataModel alloc] init];
            weakSelf.homeTableDataModel.type = @(1);
            weakSelf.homeTableDataModel.title = @"人脉推荐";
            weakSelf.homeTableDataModel.array = homeDataModel.mayknowpeople;
            [weakSelf initTableViewHeaderView];
            
            UserModel *model = [DataModelInstance shareInstance].userModel;
            model.homeData = [CommonMethod paramDictIsNull:responseObject[@"data"]];
            [DataModelInstance shareInstance].userModel = model;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

#pragma mark --- 新版本
- (void)getVersionHttpData{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [self requstType:RequestType_Get apiName:API_NAME_GET_VERSION paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        NSString *localVersion = [[[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleShortVersionString"] stringByReplacingOccurrencesOfString:@"." withString:@""];
        NSString *version = [[CommonMethod paramStringIsNull:responseObject[@"version"]] stringByReplacingOccurrencesOfString:@"." withString:@""];
        if(![version hasSuffix:@"b"]&&version.integerValue>localVersion.integerValue){
            NSNumber *forceupdate = [CommonMethod paramNumberIsNull:responseObject[@"forceupdate"]];
            [weakSelf updateVersion:[[CommonMethod paramStringIsNull:responseObject[@"describe"]] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"] version:[CommonMethod paramStringIsNull:responseObject[@"version"]] forceupdate:forceupdate];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

//版本更新弹出框
- (void)updateVersion:(NSString*)describe version:(NSString*)version forceupdate:(NSNumber*)forceupdate{
    NSString *msg = [NSString stringWithFormat:@"【v%@更新提示】\n%@",version,describe];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIView *subView = alertController.view.subviews[0];
    for(int i=0; i<4;i++){
        if(subView.subviews.count){
            subView = subView.subviews[0];
        }else{
            break;
        }
        if(i==3){
            UILabel *message = subView.subviews[1];
            message.textAlignment = NSTextAlignmentLeft;
        }
    }
    if(forceupdate.integerValue == 1){
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            //        exit(0);
        }];
        [alertController addAction:cancelAction];
    }
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"立即升级"style:UIAlertActionStyleDestructive handler:^(UIAlertAction*action) {
        NSURL *url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/cn/app/jin-mai+/id1112805191?mt=8"];
        [[UIApplication sharedApplication]openURL:url];
        if(forceupdate.integerValue == 1){
            exit(0);
        }
    }];
    [alertController addAction:otherAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark --- 首页咖啡活动宣传图
- (void)loadHttpRCMListData{
    __weak typeof(self) weakSelf = self;
    _showNetWork = NO;
    [self requstType:RequestType_Get apiName:API_NAME_GET_RCMLIST paramDict:nil hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud){
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [weakSelf.bannerArray removeAllObjects];
            for(NSDictionary *dict in [CommonMethod paramArrayIsNull:responseObject[@"data"]]){
                BannerModel *model = [[BannerModel alloc] initWithDict:dict];
                if([CommonMethod paramStringIsNull:model.url].length){
                    [weakSelf.bannerArray addObject:model];
                }
            }
            [weakSelf initTableViewHeaderView];
            UserModel *model = [DataModelInstance shareInstance].userModel;
            model.rcmListData = [CommonMethod paramArrayIsNull:responseObject[@"data"]];
            [DataModelInstance shareInstance].userModel = model;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
   
}

#pragma mark ---- 是否直播
- (void)loadLiveVideoData{
    [self requstType:RequestType_Get apiName:API_NAME_ACTIVITYLIVEVIDEO_LIST paramDict:nil hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSDictionary *dict = [CommonMethod paramDictIsNull:[responseObject objectForKey:@"data"]];
         
            self.myActivityModel = [[MyActivityModel alloc]initWithDict:dict];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];

}
#pragma mark --- 登录广告
- (void)loadHttpAdvertisementData{
    [self requstType:RequestType_Get apiName:API_NAME_GET_LOGIN_ADVERT paramDict:nil hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if(responseObject[@"data"]){
                [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"data"] forKey:LOGIN_ADVERTISEMENT_DATA];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }else{
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_ADVERTISEMENT_DATA];
            }
        }else{
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_ADVERTISEMENT_DATA];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.listArray.count){
        return self.listArray.count;
    }else if(_showNetWork){
        return 1;
    }else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.listArray.count){
        if([self.listArray[indexPath.row] isKindOfClass:[DynamicModel class]]){
            DynamicModel *model = self.listArray[indexPath.row];
            return model.cellHeight;
        }else{
            HomeRCMModel *model = self.listArray[indexPath.row];
            return model.cellHeight;
        }
    }else{
        return 300;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.listArray.count){
        if([self.listArray[indexPath.row] isKindOfClass:[HomeRCMModel class]]){
            HomeRCMModel *model = self.listArray[indexPath.row];
            if([CommonMethod paramNumberIsNull:model.type].integerValue == RecommendType_FriendAddFriend){//好友xxx认识了
                [(RecommendCell*)cell updateDisplayFAF:model];
            }else if([CommonMethod paramNumberIsNull:model.type].integerValue == RecommendType_MayInterestIndustry){//感兴趣的行业
                [(RecommendCell*)cell updateDisplayMayInterestIndustry:model];
            }else{
                [(RecommendCell*)cell updateDisplay:model];
            }
        }
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.listArray.count){
        if([self.listArray[indexPath.row] isKindOfClass:[DynamicModel class]]){
            DynamicModel *model = self.listArray[indexPath.row];
            NSInteger dynamic_id = model.dynamic_id.integerValue;
            static NSString *identifier;
            identifier = [NSString stringWithFormat:@"dynameic-%@", Cell_Index_key(dynamic_id)];
            DynamicCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if(!cell){
                cell = [[DynamicCell alloc] initWithDataModel:model identifier:identifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                __weak typeof(self) weakSelf = self;
                [self.runloopTask addTask:^{
                    DynamicModel *model = weakSelf.listArray[indexPath.row];
                    [(DynamicCell*)cell updateDisplay:model];
                }];
            }
            __weak typeof(self) weakSelf = self;
            cell.refreshDynamicCell = ^(DynamicCell *dc){
                [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:dc.tag inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            };
            cell.deleteDynamicCell = ^(DynamicCell *delCell){
                if(weakSelf.listArray.count > delCell.tag){
                    [weakSelf.listArray removeObjectAtIndex:delCell.tag];
                }
                [weakSelf.tableView beginUpdates];
                [weakSelf.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:delCell.tag inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                [weakSelf.tableView endUpdates];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                });
                if(weakSelf.listArray.count==0){
                    [weakSelf.tableView.mj_header beginRefreshing];
                }
            };
            cell.deleteUserDynamic = ^(NSNumber *userId){
                NSMutableArray *tmpList = [NSMutableArray array];
                for(int i=0; i<weakSelf.listArray.count; i++){
                    if([weakSelf.listArray[i] isKindOfClass:[DynamicModel class]]){
                        DynamicModel *model = weakSelf.listArray[i];
                        if(model.userModel.user_id.integerValue != userId.integerValue){
                            [tmpList addObject:weakSelf.listArray[i]];
                        }
                    }else{
                        [tmpList addObject:weakSelf.listArray[i]];
                    }
                }
                weakSelf.listArray = tmpList;
                [weakSelf.tableView reloadData];
                if(weakSelf.listArray.count==0){
                    [weakSelf.tableView.mj_header beginRefreshing];
                }
            };
            cell.attentUser = ^(BOOL isAttent){
                for(DynamicModel *tmpModel in weakSelf.listArray){
                    if(tmpModel.userModel.user_id.integerValue == model.userModel.user_id.integerValue){
                        if(isAttent){
                            tmpModel.userModel.relationship = @"关注";
                        }else{
                            tmpModel.userModel.relationship = @"推荐";
                        }
                    }
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                });
            };
            return cell;
        }else{
            HomeRCMModel *model = self.listArray[indexPath.row];
            static NSString *identifier;
            if([CommonMethod paramNumberIsNull:model.type].integerValue == RecommendType_FriendAddFriend){//好友xxx认识了
                identifier = @"RecommendCellFAF";
            }else if([CommonMethod paramNumberIsNull:model.type].integerValue == RecommendType_MayInterestIndustry){//感兴趣的行业
                identifier = @"RecommendCellMII";
            }else if([CommonMethod paramStringIsNull:model.image].length){
                identifier = @"RecommendCellCover";
            }else{
                identifier = @"RecommendCellNoCover";
            }
            RecommendCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            
            if(!cell){
                cell = [CommonMethod getViewFromNib:identifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.tag = indexPath.row;
            }
            
            __weak typeof(self) weakSelf = self;
            cell.deleteRecommendCell = ^(RecommendCell *delCell){
                if(weakSelf.listArray.count > delCell.tag){
                    [weakSelf.listArray removeObjectAtIndex:delCell.tag];
                }
                [weakSelf.tableView beginUpdates];
                [weakSelf.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:delCell.tag inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                [weakSelf.tableView endUpdates];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                });
                if(weakSelf.listArray.count==0){
                    [weakSelf.tableView.mj_header beginRefreshing];
                }
            };
            return cell;
        }
    }else{
        static NSString *identify = @"";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"NONetWorkTableViewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.listArray.count){
        if([self.listArray[indexPath.row] isKindOfClass:[DynamicModel class]]){
            DynamicModel *model = self.listArray[indexPath.row];
            if(model.dynamic_id.integerValue > 0 && model.parent_status.integerValue<4){
                __weak typeof(self) weakSelf = self;
                VariousDetailController *vc = [[VariousDetailController alloc] init];
                vc.dynamicid = model.dynamic_id;
                vc.deleteDynamicDetail = ^(NSNumber *dynamicid){
                    for(DynamicModel *tmpModel in weakSelf.listArray){
                        if(tmpModel.dynamic_id.integerValue == dynamicid.integerValue){
                            [weakSelf.listArray removeObject:tmpModel];
                            break;
                        }
                    }
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakSelf.tableView reloadData];
                    });
                    if(weakSelf.listArray.count==0){
                        [weakSelf.tableView.mj_header beginRefreshing];
                    }
                };
                vc.attentUser = ^(BOOL isAttent){
                    for(DynamicModel *tmpModel in weakSelf.listArray){
                        if(tmpModel.userModel.user_id.integerValue == model.userModel.user_id.integerValue){
                            if(isAttent){
                                tmpModel.userModel.relationship = @"关注";
                            }else{
                                tmpModel.userModel.relationship = @"推荐";
                            }
                        }
                    }
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakSelf.tableView reloadData];
                    });
                };
                [self.navigationController pushViewController:vc animated:YES];
            }
        }else{
            HomeRCMModel *model = self.listArray[indexPath.row];
            if([CommonMethod paramNumberIsNull:model.rfid].integerValue){
                [self clickedRCMContentHttp:model];
            }
            if(model.type.integerValue == RecommendType_Topic){
                TopicViewController *vc = [[TopicViewController alloc] init];
                vc.subjectId = model.contentid;
                [self.navigationController pushViewController:vc animated:YES];
            }else if(model.type.integerValue == RecommendType_Activity){
                ActivityDetailController *vc = [[ActivityDetailController alloc] init];
                vc.activityid = model.contentid;
                [self.navigationController pushViewController:vc animated:YES];
            }else if(model.type.integerValue == RecommendType_Post){
                InformationDetailController *vc = [[InformationDetailController alloc] init];
                vc.postID = model.contentid;
                [self.navigationController pushViewController:vc animated:YES];
            }else if(model.type.integerValue == RecommendType_FriendAddFriend){
                FriendFriendsViewController *vc = [[FriendFriendsViewController alloc] init];
                vc.model = model;
                [self.navigationController pushViewController:vc animated:YES];
            }
            [[AppDelegate shareInstance] setZhugeTrack:@"点击推荐内容" properties:@{@"tags":[CommonMethod paramStringIsNull:model.tag]}];
        }
    }else{
        [self loadHttpNewHomeData:YES];
    }
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    NSLog(@"----%lu----", (unsigned long)self.tableView.visibleCells.count);
////    self.tableView.
//}

//纪录点击的推荐内容
- (void)clickedRCMContentHttp:(HomeRCMModel*)model{
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:model.rfid forKey:@"rfid"];
    [self requstType:RequestType_Post apiName:API_NAME_POST_DYNAMIC_CLICK_RCM paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

#pragma mark ------- 透传消息(首页动态未读消息数)
- (void)didReceiveCmdMessages:(NSArray *)aCmdMessages{
    for(EMMessage *message in aCmdMessages){
        if ([message.from isEqualToString:@"jm_assistant"]){
            NSDictionary *dict = message.ext;
            NSNumber *type = [CommonMethod paramNumberIsNull:dict[@"type"]];
            if(type.integerValue == 3){
                _showMessageNum = [CommonMethod paramNumberIsNull:dict[@"notecount"]].integerValue;
                [[AppDelegate shareInstance] showUnreadCountViewItemNO:0 unReadCountSum:_showMessageNum];
                [self initTableViewHeaderView];
                break;
            }
        }
    }
}

//上传动态
- (void)uploadDynamicData{
    if(_isUploading||_showNetWork){
        return;
    }
    BOOL canPublish = YES;
    NSArray *array = [CommonMethod paramArrayIsNull:[DataModelInstance shareInstance].userModel.noUploadDynamicData];
    NSInteger dynamicIndex = 0;
    for(NSDictionary *dict in array){
        if([CommonMethod paramStringIsNull:dict[@"image"]].length){
            NSArray *imageArray = [CommonMethod paramArrayIsNull:[[CommonMethod paramStringIsNull:dict[@"image"]] componentsSeparatedByString:@","]];
            for(int i=0; i<imageArray.count; i++){
                if(![imageArray[i] hasPrefix:@"http://"]){
                    _isUploading = YES;
                    [self uploadImageHttp:i dict:dict dynamicIndex:dynamicIndex];
                    canPublish = NO;
                    return;
                }
            }
        }
        if(canPublish&&!_isUploading){
            _isUploading = YES;
            [self createDynamicHttp:dict];
            break;
        }
        dynamicIndex++;
    }
}

#pragma mark - 创建动态
- (void)createDynamicHttp:(NSDictionary*)dict{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    
    NSString *content = dict[@"content"];
    if(content.length){
        [requestDict setObject:content forKey:@"content"];
    }
    if([CommonMethod paramStringIsNull:dict[@"image"]].length){
        [requestDict setObject:dict[@"image"] forKey:@"image"];
    }
    [self requstType:RequestType_Post apiName:API_NAME_POST_DYNAMIC_CREATE paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            for(int index=0; index<weakSelf.listArray.count;index++){
                if(![weakSelf.listArray[index] isKindOfClass:[DynamicModel class]]){
                    continue;
                }
                DynamicModel *model = weakSelf.listArray[index];
                if(model.dynamic_id.integerValue == [CommonMethod paramNumberIsNull:dict[@"dynamic_id"]].integerValue){
                    DynamicModel *dymodel = [[DynamicModel alloc] initWithDict:[CommonMethod paramDictIsNull:responseObject[@"data"]] cellTag:index];
                    weakSelf.listArray[index] = dymodel;
                    
                    DynamicCell *cell = [weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                    [cell updateDisplayEnableEdit:dymodel];
                    
                    UserModel *model = [DataModelInstance shareInstance].userModel;
                    [[AppDelegate shareInstance] setZhugeTrack:@"发布动态" properties:@{@"industry":[CommonMethod paramStringIsNull:model.industry], @"business":[CommonMethod paramStringIsNull:model.business],@"city":[CommonMethod paramStringIsNull:model.address], @"dynamicId":[CommonMethod paramNumberIsNull:dymodel.dynamic_id],@"dynamicType":[CommonMethod paramNumberIsNull:dymodel.type],@"dynamicExtype":[CommonMethod paramNumberIsNull:dymodel.exttype]}];
                    NSMutableArray *array = [[CommonMethod paramArrayIsNull:[DataModelInstance shareInstance].userModel.noUploadDynamicData] mutableCopy];
                    NSInteger row = 0;
                    for(NSDictionary *tmpDict in array){
                        if([CommonMethod paramNumberIsNull:tmpDict[@"dynamic_id"]].integerValue == [CommonMethod paramNumberIsNull:dict[@"dynamic_id"]].integerValue){
                            [array removeObjectAtIndex:row];
                            break;
                        }
                        row++;
                    }
                    UserModel *userModel = [DataModelInstance shareInstance].userModel;
                    userModel.noUploadDynamicData = array;
                    [DataModelInstance shareInstance].userModel = userModel;
                    if(array.count==0){
                        [weakSelf initTableViewHeaderView];
                    }
                    break;
                }
            }
        }
        [weakSelf cancelAllRequest];
        _isUploading = NO;
        [weakSelf uploadDynamicData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        if(_showDynamicUpload != ([DataModelInstance shareInstance].userModel.noUploadDynamicData.count>0)){
            _showDynamicUpload = [DataModelInstance shareInstance].userModel.noUploadDynamicData.count>0;
            [weakSelf initTableViewHeaderView];
        }
        _isUploading = NO;
    }];
}

//上传图片
- (void)uploadImageHttp:(NSInteger)index dict:(NSDictionary*)dict dynamicIndex:(NSInteger)dynamicIndex{
    NSMutableArray *imageArray = [[CommonMethod paramArrayIsNull:[dict[@"image"] componentsSeparatedByString:@","]] mutableCopy];
    NSString *documentsPath = [NSString stringWithFormat:@"%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/dynamic"], imageArray[index]];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:documentsPath];
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    if(image){
        NSData *imageData = UIImageJPEGRepresentation(image, 1);
        [requestDict setObject:imageData forKey:@"pphoto"];
    }
    [self requstType:RequestType_UPLOAD_IMG apiName:API_NAME_UPLOAD_IMAGE paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            NSString *urlStr = [responseObject objectForKey:@"msg"];
            imageArray[index] = urlStr;
            [dict setValue:[imageArray componentsJoinedByString:@","] forKey:@"image"];
            NSMutableArray *array = [[CommonMethod paramArrayIsNull:[DataModelInstance shareInstance].userModel.noUploadDynamicData] mutableCopy];
            array[dynamicIndex] = dict;
            UserModel *userModel = [DataModelInstance shareInstance].userModel;
            userModel.noUploadDynamicData = array;
            [DataModelInstance shareInstance].userModel = userModel;
        }
        _isUploading = NO;
        [weakSelf uploadDynamicData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        if(_showDynamicUpload != ([DataModelInstance shareInstance].userModel.noUploadDynamicData.count>0)){
            _showDynamicUpload = [DataModelInstance shareInstance].userModel.noUploadDynamicData.count>0;
            [weakSelf initTableViewHeaderView];
        }
        _isUploading = NO;
    }];
}

- (void)cleanFolder{
    //这里将图片放在沙盒的documents文件夹中
    NSString *DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/dynamic"];
    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:DocumentsPath]){
        NSArray *array = [fileManager subpathsAtPath:DocumentsPath];
        for(NSString *imageName in array){
            NSString *ImagePath = [[NSString alloc] initWithFormat:@"/%@.png",imageName];
            [fileManager removeItemAtPath:[DocumentsPath stringByAppendingString:ImagePath] error:nil];
        }
    }
}
#pragma mark ------ 获取同伴修改
- (void)getChangeIformation{
    if (self.nameArray) {
        self.nameArray = nil;
    }
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
     [requestDict setObject:[NSString stringWithFormat:@"/%@",[DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_USER_EDIT_TIP paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            NSDictionary *dic = [CommonMethod paramDictIsNull:responseObject[@"data"]];
            weakSelf.nameArray = [CommonMethod paramArrayIsNull:dic[@"names"]];
            weakSelf.changeMsg = [CommonMethod paramStringIsNull:dic[@"msg"]];
            [weakSelf initTableViewHeaderView];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        
    }];
  
}
@end
