

//
//  MyHomepageController.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/3.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "MyHomepageController.h"
#import "MyMessageCell.h"
#import "CofferCell.h"
#import "VideoCell.h"
#import "MenuView.h"
#import "WallCofferController.h"
#import "NewAddFriendController.h"
#import "TaContactsCtr.h"
#import "ShareView.h"
#import "NONetWorkTableViewCell.h"
#import "ChoiceFriendViewController.h"
#import "ChatViewController.h"
#import "EditPersonalInfoViewController.h"
#import "MyCofferViewController.h"
#import "MyConnectionsController.h"

#import "IdentityController.h"
#import "PassReviewController.h"
#import "ReviewController.h"
#import "NotPassController.h"
#import "ShareNormalView.h"

#import "GooAtCell.h"
#import "SubjectInterviewCell.h"
#import "WorkHistoryCell.h"
#import "LookHistoryCell.h"

#import "ShowPhoneView.h"
#import "SearchViewController.h"

#import "RichTextViewController.h"
#import "WorkHistoryController.h"
#import "FirstLaunchGuideView.h"


#import "CofferAlearGetView.h"
#import "GetMyselfCoffer.h"
#import "GetSucceedCofferView.h"
#import "AlreadHaveCofferView.h"

#import "GetWallCoffeeDetailViewController.h"
#import "VistorsListViewController.h"

#import "MyHomeTopicCell.h"

#import "InformationDetailController.h"

#import "MyDynamicCell.h"
#import "MyDynamicListController.h"

@interface MyHomepageController ()<MyMessageCellDelegate,GooAtCellDelegate,VideoCellDelegate>{
    BOOL _isPresentVC;
}
@property (nonatomic,strong) MenuView * menuView;
@property (nonatomic,assign) BOOL alreadShow;
@property (nonatomic,assign) BOOL flag;
@property (nonatomic,strong) UIView *tabBarView;
@property (nonatomic,strong) UIButton *backBtn;

@property (nonatomic,strong) UIButton *recommendBtn;
@property (nonatomic,strong) UILabel *titleTabBaeLabel;
@property (nonatomic,strong) UIButton *attentionBtn;
@property (nonatomic,strong) UIButton *addFriendBtn;
@property (nonatomic,assign) BOOL  netWorkStat;
@property (nonatomic,strong) TaMessageModel  *taModel;
@property (nonatomic,strong) CofferModel *coffModel;
@property (nonatomic,strong) PeopleModel *popleModel;
@property (nonatomic,strong) SubjectModel *subModel;
@property (nonatomic,strong) ShareView *shawView;
@property (nonatomic,strong) workHistryModel *workModel;
@property (nonatomic,strong) MyTopicModel  *topicModel;
@property (nonatomic,strong) LookHistoryModel *lookModel;
@property (nonatomic,strong) UIView *coverView;
@property (nonatomic,strong) NSString *attestationStr;
@property (nonatomic,strong) NSString *imageUrl;
@property (nonatomic,strong) UIView *backHeaderView;
@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) UIView *footView;
@property (nonatomic,strong) UIView *videoPlayView;
@property (nonatomic,strong) NSMutableArray *workArray;
@property (nonatomic,strong) NSMutableArray *lookArray;
@property (nonatomic,strong) ShowPhoneView *showPhoneView;
@property (nonatomic,assign) CGFloat phoneHeigth;
//视频播放
@property (nonatomic,strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic,strong) UIView *playView;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) UISlider *playableProgress;
@property (nonatomic,strong) UIView *showImageView;

//我的主页
@property (nonatomic,assign) BOOL isMyHomePage;
@property (nonatomic,strong) UIImageView *headerImageView;
@property (nonatomic,assign) NSInteger taAttPage;
@property (nonatomic, assign) BOOL  loadAllover;
@property (nonatomic,strong) DynamicModel *dymodel;

@end

@implementation MyHomepageController

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
  
    if (self.stayTapy == YES) {
        _isPresentVC = YES;;
    }else{
         _isPresentVC = NO;
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
   
    if(self.isMyHomePage){
        [self createrIDStart];
    }
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CheckMoreDynamicAction) name:@"CheckMoreDynamic" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView:) name:@"reloadTableView" object:nil];
}

- (void)reloadTableView:(NSNotification *)notification{
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.moviePlayer pause];
    self.showImageView.hidden = NO;
    if([[UIApplication sharedApplication] statusBarStyle] == UIStatusBarStyleDefault && _isPresentVC == NO) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loadAllover = NO;
    self.view.backgroundColor = kTableViewBgColor;
    self.workArray = [NSMutableArray new];
    self.lookArray = [NSMutableArray new];
    self.flag = YES;
    if([DataModelInstance shareInstance].userModel.userId.integerValue == self.userID.integerValue){
        self.isMyHomePage = YES;
    }
    
    if (self.isMyHomePage) {
        if(![[NSUserDefaults standardUserDefaults] boolForKey:FirstLaunchGuideViewMarkMySelf]){
            //第一次功能介绍引导
             [self showFirstLaunchGuideView];
        }
    }
  
    self.taModel = [[TaMessageModel alloc] init];
    self.taModel.realname = @"姓名";
    self.taModel.city = @"工作地点";
    self.taModel.workyearstr = @"从业时间";
    [self createrTabBerView];
//    [self cretaerTabViewHeaderImage];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self lookHistoryGetData:1];
    });
    [self getTaMessageInformation];
    if (self.zbarModel) {
        self.alreadShow = YES;
        if (self.zbarModel.rst.integerValue != 1){
            [self scaningCofferResultShow];
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netWorkChangePlay:) name:kReachabilityChangedNotification object:nil];

  
  
}
#pragma mark ------ 查看更多动态
- (void)CheckMoreDynamicAction{
    MyDynamicListController *dynamic = [[MyDynamicListController alloc]init];
    
    dynamic.userID = self.userID;
    [self.navigationController pushViewController:dynamic animated:YES];
    
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 网络变化
- (void)netWorkChangePlay:(NSNotification *)netWorkChange{
    if (self.moviePlayer) {
        Reachability *reach = [netWorkChange object];
        if (reach.currentReachabilityStatus == ReachableViaWWAN) {
            if (self.moviePlayer != nil) {
                [self.moviePlayer pause];
                self.showImageView.hidden = NO;
            }
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"您当前正在使用移动网络,继续播放将消耗流量" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
            } confirm:^{
                [self.moviePlayer play];
                self.showImageView.hidden = YES;
            }];
        }else if (reach.currentReachabilityStatus == NotReachable){
            if (self.moviePlayer != nil) {
                [self.moviePlayer pause];
                self.showImageView.hidden = NO;
            }
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"当前网络无连接,请检查网络连接" cancelButtonTitle:nil otherButtonTitle:@"确定" cancle:^{
            } confirm:^{
            }];
        }
    }
}

- (void)scaningCofferResultShow{
    /*
     0 --- 失效
     1-正常
     2-别人领取过这杯咖啡
     3-自己领取过这杯咖啡
     4-已领取过此人的其他咖啡并兑换，
     5-领取自己的咖啡
     6 -已有咖啡未兑换
     */

    if (self.zbarModel.rst.integerValue == 0) {
        GetMyselfCoffer *view = [CommonMethod getViewFromNib:@"GetMyselfCoffer"];
        view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        [view ceraterTitleLabelShow:NO];
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    }else if (self.zbarModel.rst.integerValue == 2){
        GetMyselfCoffer *view = [CommonMethod getViewFromNib:@"GetMyselfCoffer"];
        view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    }else if (self.zbarModel.rst.integerValue == 3){
        GetSucceedCofferView *view = [CommonMethod getViewFromNib:@"GetSucceedCofferView"];
        view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        [view createrGetCofferCoverImage:self.zbarModel.headimg isMyGet:NO];
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    }else if (self.zbarModel.rst.integerValue == 4) {
        CofferAlearGetView *view = [CommonMethod getViewFromNib:@"CofferAlearGetView"];
        view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    }else if (self.zbarModel.rst.integerValue == 6){
        AlreadHaveCofferView *view = [CommonMethod getViewFromNib:@"AlreadHaveCofferView"];
        view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        view.checkGetCofferDetail = ^{
            GetWallCoffeeDetailViewController *vc = [CommonMethod getVCFromNib:[GetWallCoffeeDetailViewController class]];
            vc.isMygetCoffee = YES;
            vc.coffeegetid = self.zbarModel.getid;
            [self.navigationController pushViewController:vc animated:YES];
        };
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    }
}

#pragma mark - 首页功能引导页
- (void)showFirstLaunchGuideView{
    FirstLaunchGuideView *view = [CommonMethod getViewFromNib:@"FirstLaunchGuideView"];
    view.viewType = FLGV_Type_MyPage;
    [view newUserGuide];
    view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
}

#pragma mark --- 谁看过他的历史
- (void)lookHistoryGetData:(NSInteger)page{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    NSString *type;
    if (self.isMyHomePage) {
        type = API_NAME_GET_VISITORS;
        [requestDict setObject:[NSString stringWithFormat:@"/%@/%@/%ld", [DataModelInstance shareInstance].userModel.userId,self.userID,(long)page] forKey:@"param"];
    }else{
        type = API_NAME_USER_LOOKAT_HISTRY;
        [requestDict setObject:[NSString stringWithFormat:@"/%@/%@", [DataModelInstance shareInstance].userModel.userId,self.userID] forKey:@"param"];
    }
    [self requstType:RequestType_Get apiName:type paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if (weakSelf.tableView.mj_footer.isRefreshing) {
            [weakSelf.tableView.mj_footer endRefreshing];
        }
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *subArray = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            if (weakSelf.isMyHomePage) {
                NSInteger index = [CommonMethod paramNumberIsNull:[responseObject objectForKey:@"msg"]].integerValue;
                if (index > 10) {
                      [weakSelf createrTableViewFootView];
                }
            }
            for (NSDictionary *subDic in subArray) {
                weakSelf.lookModel = [[LookHistoryModel alloc] initWithDict:subDic];
                [weakSelf.lookArray addObject:weakSelf.lookModel];
            }
            [weakSelf.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        if (weakSelf.tableView.mj_footer.isRefreshing) {
            [weakSelf.tableView.mj_footer endRefreshing];
        }
    }];
}

#pragma mark --- 网络请求数据，个人主页data
- (void)getTaMessageInformation{
    if (self.workArray) {
        [self.workArray removeAllObjects];
    }
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@", [DataModelInstance shareInstance].userModel.userId,self.userID] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_USER_GET_TAHOMEPAGE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        weakSelf.recommendBtn.hidden = NO;
        [hud hideAnimated:YES];
        weakSelf.netWorkStat = NO;
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSDictionary *dict = [CommonMethod paramDictIsNull:[responseObject objectForKey:@"data"]];
            [DataModelInstance shareInstance].userModel.goodjobs = dict[@"business"];
            weakSelf.taModel = [[TaMessageModel alloc] initWithDict:dict];
            weakSelf.topicModel = [[MyTopicModel alloc] initWithDict:dict[@"review"]];
            weakSelf.taModel.isMyHomePage = weakSelf.isMyHomePage;
            NSDictionary *dynamicDic = [CommonMethod paramDictIsNull:[dict objectForKey:@"dynamic"]];
            
              weakSelf.dymodel = [[DynamicModel alloc] initWithDict:dynamicDic];

            NSDictionary *subDic = [CommonMethod paramDictIsNull:[dict objectForKey:@"coffee"]];
            weakSelf.coffModel = [[CofferModel alloc] initWithDict:subDic];
            NSDictionary *peopleDic = [CommonMethod paramDictIsNull:[dict objectForKey:@"connections"]];
            NSDictionary *subMarkDic = [CommonMethod paramDictIsNull:[dict objectForKey:@"djtalk"]];
            if (subMarkDic != nil) {
                weakSelf.subModel = [[SubjectModel alloc] initWithDict:subMarkDic];
            }
            NSArray *workArray = [CommonMethod paramArrayIsNull:[dict objectForKey:@"career"]];
            if (workArray.count > 0) {
                for (NSDictionary *workDict in workArray) {
                    weakSelf.workModel = [[workHistryModel alloc] initWithDict:workDict];
                    [weakSelf.workArray addObject:weakSelf.workModel];
                }
            }
            
            //诸葛监控
            if (!self.isMyHomePage) {
                 [[AppDelegate shareInstance] setZhugeTrack:@"浏览用户" properties:@{@"useID":self.userID, @"company":[CommonMethod paramStringIsNull:self.taModel.company],@"position":[CommonMethod paramStringIsNull:self.taModel.position],@"address":self.taModel.city,@"goodAt":[[CommonMethod paramArrayIsNull:self.taModel.business]componentsJoinedByString:@","],@"industry":[CommonMethod paramStringIsNull:self.taModel.industry]}];
             
            }
            
            weakSelf.popleModel = [[PeopleModel alloc] initWithDict:peopleDic];
            self.loadAllover = YES;
            [weakSelf.tableView reloadData];
            [weakSelf cretaerTabViewHeaderImage];
            if (!weakSelf.isMyHomePage) {
                [weakSelf createrFootView];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        weakSelf.recommendBtn.hidden = YES;
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        weakSelf.netWorkStat = YES;
        [weakSelf.tableView reloadData];
    }];
} 
#pragma mark -------- 底部按钮
- (void)createrFootView{
    self.footView = [NSHelper createrViewFrame:CGRectMake(0, HEIGHT - 55, WIDTH, 55) backColor:@"F7F7F7"];
    self.footView.userInteractionEnabled = YES;
    [self.view addSubview:self.footView];
    UIButton *senderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    senderBtn.frame = CGRectMake(38, 8, WIDTH - 76, 40);
    [senderBtn.layer setMasksToBounds:YES];
    [senderBtn.layer setCornerRadius:5.0]; //设置矩形四个圆角半径
    senderBtn.backgroundColor = [UIColor colorWithHexString:@"E24943"];
    UIButton *phoneBtn = [NSHelper createButton:CGRectMake(WIDTH - 65, 8, 40, 40) title:@"" unSelectImage:nil selectImage:nil target:self selector:@selector(showPhoneNumber)];
    [phoneBtn setBackgroundImage:[UIImage imageNamed:@"btn_zy_lxfx"] forState:UIControlStateNormal];
    if (self.taModel.isfriend.integerValue == 0) {
        if (self.alreadShow == YES) {
            if (self.zbarModel.rst.integerValue == 1) {
                [senderBtn setTitle:@"领取Ta的咖啡，认识一下" forState:UIControlStateNormal];
                [senderBtn addTarget:self action:@selector(editGetCofferMessage) forControlEvents:UIControlEventTouchUpInside];
            }else{
                [senderBtn setTitle:@"加为好友" forState:UIControlStateNormal];
                [senderBtn addTarget:self action:@selector(addFriendBtnnAction) forControlEvents:UIControlEventTouchUpInside];
            }

        }else{
            [senderBtn setTitle:@"加为好友" forState:UIControlStateNormal];
            [senderBtn addTarget:self action:@selector(addFriendBtnnAction) forControlEvents:UIControlEventTouchUpInside];
        }
    }else{
        if (self.alreadShow == YES) {
            if (self.zbarModel.rst.integerValue == 1) {
                [senderBtn setTitle:@"领取Ta的咖啡" forState:UIControlStateNormal];
                [senderBtn addTarget:self action:@selector(editGetCofferMessage) forControlEvents:UIControlEventTouchUpInside];
            }else{
                [senderBtn setTitle:@"发送消息" forState:UIControlStateNormal];
                [senderBtn addTarget:self action:@selector(contactsBtnAction) forControlEvents:UIControlEventTouchUpInside];
            }

        }else{
            senderBtn.frame = CGRectMake(25, 8, WIDTH - 100, 40);
            [senderBtn setTitle:@"发送消息" forState:UIControlStateNormal];
            [senderBtn addTarget:self action:@selector(contactsBtnAction) forControlEvents:UIControlEventTouchUpInside];
            [self.footView addSubview:phoneBtn];
        }
    }
    [self.footView addSubview:senderBtn];
}

#pragma mark ------ 领取咖啡留言
- (void)editGetCofferMessage{
     _isPresentVC = YES;
    RichTextViewController *vc = [CommonMethod getVCFromNib:[RichTextViewController class]];
    vc.isCoffer = YES;
    vc.cofferId = self.zbarModel.coffid;
    vc.scaningCofferSucceedRestule = ^(BOOL isShow){
        if (isShow) {
            GetSucceedCofferView *view = [CommonMethod getViewFromNib:@"GetSucceedCofferView"];
            view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
            [view createrGetCofferCoverImage:self.zbarModel.headimg isMyGet:YES];
            [[UIApplication sharedApplication].keyWindow addSubview:view];
            self.alreadShow = NO;
            [self createrFootView];
        }else{
            GetMyselfCoffer *view = [CommonMethod getViewFromNib:@"GetMyselfCoffer"];
            view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
            [[UIApplication sharedApplication].keyWindow addSubview:view];
        }
    };
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark ----------- 电话
- (void)showPhoneNumber{
    self.phoneHeigth = 175;
    if (self.coverView == nil) {
        self.coverView = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, HEIGHT ) backColor:@"41464E"];
    }
    [self.view addSubview:self.coverView];
    self.coverView.backgroundColor = [UIColor colorWithRed:65.0/255.0 green:70.0/255.0 blue:78.0/255 alpha:0.7];
    self.coverView.userInteractionEnabled = YES;
    UITapGestureRecognizer *cancleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancleCoveView)];
    [self.coverView addGestureRecognizer:cancleTap];
    if (self.showPhoneView == nil) {
        self.showPhoneView = [[ShowPhoneView alloc]initWithFrame:CGRectMake(0, HEIGHT , WIDTH, self.phoneHeigth)];
        [self.coverView addSubview:self.showPhoneView];
    }
    
   if (self.taModel.phone.length > 0) {
       self.showPhoneView.phoneNumbStr = self.taModel.phone;
    }else{
        self.showPhoneView.phoneNumbStr = @"--";
    }
    if (self.taModel.email.length > 0) {
        self.showPhoneView.emailStr = self.taModel.email;
    }else{
        self.showPhoneView.emailStr = @"--";
    }
    if (self.taModel.weixin.length > 0) {
        self.showPhoneView.weixinNumberStr = self.taModel.weixin;
    }else{
        self.showPhoneView.weixinNumberStr = @"--";
    }
    self.showPhoneView.canviewphone = self.taModel.canviewphone;

    [self.showPhoneView createrPhoneView];
    self.showPhoneView.userInteractionEnabled = YES;
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.showPhoneView.frame = CGRectMake(0, HEIGHT-weakSelf.phoneHeigth, WIDTH, weakSelf.phoneHeigth);
    }];
    self.showPhoneView.showPhoneViewIndex = ^(NSInteger index){
        if (index == 3) {
            [UIView animateWithDuration:0.25 animations:^{
                weakSelf.showPhoneView.frame = CGRectMake(0, HEIGHT, WIDTH, weakSelf.phoneHeigth);
            }completion:^(BOOL finished) {
                [weakSelf.coverView removeFromSuperview];
            }];
        }else{
            [weakSelf copyPlayVideoAction:index];
        }
    };
}

#pragma mark -------  创建导航
- (void)createrTabBerView{
    if (self.isMyHomePage) {
        [self initTableView:CGRectMake(0, 0, WIDTH,HEIGHT)];
    }else{
        [self initTableView:CGRectMake(0, 0, WIDTH,HEIGHT-55)];
    }
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
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
    
    if (!self.isMyHomePage) {
        self.recommendBtn = [NSHelper createButton:CGRectMake(WIDTH - 40 , 26, 32, 32) title:nil unSelectImage:[UIImage imageNamed:@"btn_tab_more_normal"] selectImage:nil target:self selector:@selector(recommendBtnAction)];
        [self.backHeaderView addSubview:self.recommendBtn];
    }
    
    self.titleTabBaeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 24, WIDTH, 30)];
    if(self.isMyHomePage){
        self.titleTabBaeLabel.text = @"我的主页";
    }else{
        self.titleTabBaeLabel.text = @"Ta的主页";
    }
    self.titleTabBaeLabel.hidden = YES;
    self.titleTabBaeLabel.textAlignment = NSTextAlignmentCenter;
    [self.backHeaderView addSubview:self.titleTabBaeLabel];
}

#pragma mark -------  编辑个人信息
- (void)editInfoBtnAction{
    __weak typeof(self) weakSelf = self;
    EditPersonalInfoViewController *vc = [[EditPersonalInfoViewController alloc] init];
    vc.savePersonalInfoSuccess = ^{
        [weakSelf getTaMessageInformation];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark ---- 推荐好友
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

#pragma mark -------  聊天
- (void)contactsBtnAction{
    NSString *chartId = [NSString stringWithFormat:@"%@",self.userID];
    ChatViewController *chatVC = [[ChatViewController alloc]initWithConversationChatter:chartId conversationType:EMConversationTypeChat];
    chatVC.title = self.taModel.realname;
    chatVC.position = [NSString stringWithFormat:@"%@%@",self.taModel.company,self.taModel.position];
    chatVC.phoneNumber = self.taModel.phone;
    chatVC.pushIndex = 888;
    [self.navigationController pushViewController:chatVC animated:YES];
}

#pragma mark -------  返回
- (void)backBtnAction{
    [self.menuView showMenuWithAnimation:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -------- 导航颜色变化
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offHeight = 300;
    CGFloat heigth = scrollView.contentOffset.y;
    CGFloat alpha = heigth/offHeight;
    self.titleTabBaeLabel.hidden = NO;
    self.titleTabBaeLabel.alpha = alpha-0.1;
    self.tabBarView.alpha = alpha;
    if (heigth < offHeight/2){
        [self.backBtn setImage:[UIImage imageNamed:@"btn_tab_back_normal"] forState:UIControlStateNormal];
        
        [self.recommendBtn setImage:[UIImage imageNamed:@"btn_tab_more_normal"] forState:UIControlStateNormal];
        alpha = 1.2-alpha*2;
        self.backBtn.alpha = alpha;
        self.recommendBtn.alpha = alpha;
    }else{
        alpha = alpha*2-0.8;
        self.backBtn.alpha = alpha;
        self.recommendBtn.alpha = alpha;
        [self.backBtn setImage:[UIImage imageNamed:@"btn_tab_back"] forState:UIControlStateNormal];
        [self.recommendBtn setImage:[UIImage imageNamed:@"btn_tab_more"] forState:UIControlStateNormal];
    }
    //图片变化
    if(scrollView.contentOffset.y < 0){
        self.headerImageView.frame = CGRectMake(scrollView.contentOffset.y/2, scrollView.contentOffset.y, WIDTH-scrollView.contentOffset.y, WIDTH-scrollView.contentOffset.y);
    }
//    else{
//        self.headerImageView.frame = CGRectMake(0, scrollView.contentOffset.y, WIDTH, WIDTH-scrollView.contentOffset.y);
//    }
    //关注变化
    [self.attentionBtn removeFromSuperview];
    if (self.isMyHomePage) {
        [self.addFriendBtn removeFromSuperview];
    }
    
    if (scrollView.contentOffset.y > WIDTH - 90) {
        if (self.isMyHomePage) {
            self.attentionBtn.frame = CGRectMake(WIDTH - 80, 31, 18, 18);
            [self.backHeaderView addSubview:self.attentionBtn];
            self.addFriendBtn.frame = CGRectMake(WIDTH - 40, 31,18, 18);
            [self.backHeaderView addSubview:self.addFriendBtn];
            [self.attentionBtn setBackgroundImage:[UIImage imageNamed:@"btn_zy_shbj"] forState:UIControlStateNormal];
            [self.addFriendBtn setBackgroundImage:[UIImage imageNamed:@"btn_zy_shfx"] forState:UIControlStateNormal];
        }else{
            self.attentionBtn.frame = CGRectMake(WIDTH - 80, 32, 20, 18);
            [self.backHeaderView addSubview:self.attentionBtn];
            if (self.taModel.isattention.integerValue == 1) {
                [self.attentionBtn setBackgroundImage:[UIImage imageNamed:@"btn_zy_ygz_redsx"] forState:UIControlStateNormal];
            }else{
                [self.attentionBtn setBackgroundImage:[UIImage imageNamed:@"btn_zy_wgg_grey"] forState:UIControlStateNormal];
            }
            self.attentionBtn.tag = 1;
        }
    }else{
        if (self.isMyHomePage) {
            self.attentionBtn.frame =CGRectMake(WIDTH - 160, WIDTH - 55,70, 32);
            [self.headerView addSubview:self.attentionBtn];
            
            self.addFriendBtn.frame = CGRectMake(WIDTH - 80, WIDTH - 55,70, 32);
            [self.headerView addSubview:self.addFriendBtn];
            [self.addFriendBtn setBackgroundImage:[UIImage imageNamed:@"btn_zy_fx"] forState:UIControlStateNormal];
            [self.attentionBtn setBackgroundImage:[UIImage imageNamed:@"btn_zy_bj"] forState:UIControlStateNormal];
        }else{
            self.attentionBtn.frame = CGRectMake(WIDTH - 174, WIDTH - 55,85, 32);
            [self.headerView addSubview:self.attentionBtn];
            if (self.taModel.isattention.integerValue == 1) {
                [self.attentionBtn setBackgroundImage:[UIImage imageNamed:@"btn_zy_gz_y"] forState:UIControlStateNormal];
            }else{
                [self.attentionBtn setBackgroundImage:[UIImage imageNamed:@"btn_zy_gz_w"] forState:UIControlStateNormal];
            }
            self.attentionBtn.tag = 2;
        }
    }
}
#pragma mark -------  头视图头像
- (void)cretaerTabViewHeaderImage{
    //头视图
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, WIDTH)];
    self.headerView.userInteractionEnabled = YES;
    self.tableView.tableHeaderView = self.headerView;
    
    UIImageView *imageView = [UIImageView drawImageViewLine:CGRectMake(0, 0, WIDTH, WIDTH) bgColor:[UIColor grayColor]];
    [self.headerView addSubview:imageView];
    
      [imageView sd_setImageWithURL:[NSURL URLWithString:self.taModel.image] placeholderImage:KHeadImageDefault completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if(image==nil && [[CommonMethod paramStringIsNull:self.taModel.phone] length]){
            imageView.image = KHeadImageDefaultName(self.taModel.realname);
        }
    }];
    self.headerImageView = imageView;
    
    //视频
    UIButton *tapCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tapCameraBtn.frame = CGRectMake(20, WIDTH-55, 32, 32);
    [tapCameraBtn setBackgroundImage:kImageWithName(@"btn_zy_tdsp") forState:UIControlStateNormal];
    [tapCameraBtn addTarget:self action:@selector(tapCameraBtn) forControlEvents:UIControlEventTouchUpInside];
    if (!self.isMyHomePage) {
        if (self.taModel.video.length > 0) {
            [self.headerView addSubview:tapCameraBtn];
        }
    }else{
        [self.headerView addSubview:tapCameraBtn];
    }
    
    if (self.attentionBtn.tag == 1) {
        if (self.isMyHomePage) {
            [self.attentionBtn setBackgroundImage:[UIImage imageNamed:@"btn_zy_bj"] forState:UIControlStateNormal];
        }else{
            if (self.taModel.isattention.integerValue == 1) {
                [self.attentionBtn setBackgroundImage:[UIImage imageNamed:@"btn_zy_ygz_redsx"] forState:UIControlStateNormal];
                [self.attentionBtn removeTarget:self action:@selector(attentionBtnAction) forControlEvents:UIControlEventTouchUpInside];
                [self.attentionBtn addTarget:self action:@selector(cancleAttentionBtnAction) forControlEvents:UIControlEventTouchUpInside];
            }else{
                [self.attentionBtn setBackgroundImage:[UIImage imageNamed:@"btn_zy_wgg_grey"] forState:UIControlStateNormal];
                [self.attentionBtn removeTarget:self action:@selector(cancleAttentionBtnAction) forControlEvents:UIControlEventTouchUpInside];
                 [self.attentionBtn addTarget:self action:@selector(attentionBtnAction) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }else{
        //关注
         self.attentionBtn = [NSHelper createButton:CGRectMake(WIDTH - 174, WIDTH - 55,85, 32) title:nil unSelectImage:[UIImage imageNamed:@""] selectImage:[UIImage imageNamed:@""] target:self selector:nil];
         [self.headerView addSubview:self.attentionBtn];
       
        //编辑（关注）
        if (self.isMyHomePage) {
            self.attentionBtn.frame =CGRectMake(WIDTH - 160, WIDTH - 55,70, 32);
            [self.attentionBtn setBackgroundImage:[UIImage imageNamed:@"btn_zy_bj"] forState:UIControlStateNormal];
            [self.attentionBtn addTarget:self action:@selector(editInfoBtnAction) forControlEvents:UIControlEventTouchUpInside];
        }else{
            if(self.taModel.isattention.integerValue == 1) {
                [self.attentionBtn setBackgroundImage:[UIImage imageNamed:@"btn_zy_gz_y"] forState:UIControlStateNormal];
                [self.attentionBtn addTarget:self action:@selector(cancleAttentionBtnAction) forControlEvents:UIControlEventTouchUpInside];
            }else{
                [self.attentionBtn setBackgroundImage:[UIImage imageNamed:@"btn_zy_gz_w"] forState:UIControlStateNormal];
                [self.attentionBtn addTarget:self action:@selector(attentionBtnAction) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        self.attentionBtn.tag = 2;
    }
    //分享
    self.addFriendBtn = [NSHelper createButton:CGRectMake(WIDTH - 80, WIDTH - 55,70, 32) title:nil unSelectImage:[UIImage imageNamed:@""] selectImage:[UIImage imageNamed:@""] target:self selector:@selector(sharViewFriends)];
    [self.addFriendBtn setBackgroundImage:[UIImage imageNamed:@"btn_zy_fx"] forState:UIControlStateNormal];
    [self.headerView addSubview:self.addFriendBtn];
}
#pragma mark------  tabViewFootView
- (void)createrTableViewFootView{
    UIView *footView = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, 77) backColor:@"FFFFFF"];
    self.tableView.tableFooterView = footView;
    UIButton *refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    refreshBtn.frame = CGRectMake(62, 24, WIDTH - 124, 30);
    [refreshBtn setTitle:@"查看更多" forState:UIControlStateNormal];
    [refreshBtn setTitleColor:HEX_COLOR(@"818C9E") forState:UIControlStateNormal];
    refreshBtn.titleLabel.font = FONT_SYSTEM_SIZE(14);
    [CALayer updateControlLayer:refreshBtn.layer radius:4 borderWidth:0.5 borderColor:[UIColor grayColor].CGColor];
    [refreshBtn addTarget:self action:@selector(moreVisitoryBtnAction) forControlEvents:UIControlEventTouchUpInside];
   
    [footView addSubview:refreshBtn];
}

#pragma mark ------查看更多
- (void)moreVisitoryBtnAction{
    VistorsListViewController *vc = [[VistorsListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark ------- 拍视频自己的主页跳转他人主页播放
- (void)tapCameraBtn{
    
}

#pragma mark --------  创建视频播放器
- (void) createrVideoPlayXPver{
    self.playView = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, WIDTH) backColor:@"FFFFFF"];
    
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.3;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
//    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
//    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [self.playView.layer addAnimation:animation forKey:nil];

    self.playView.userInteractionEnabled = YES;
    self.moviePlayer = [[MPMoviePlayerController alloc]initWithContentURL:[NSURL URLWithString:self.taModel.video]];
    self.moviePlayer.view.frame = self.playView.frame;
    if (!self.isMyHomePage) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
    }
    
    //  播放器样式
    self.moviePlayer.controlStyle = MPMovieControlStyleNone;
    //  关闭播放器响应,避免抢走其他控件的触控事件
    self.moviePlayer.view.userInteractionEnabled = NO;
    [self.playView addSubview:self.moviePlayer.view];
    [self.view addSubview:self.playView];
    
    // playalbeslider
    self.playableProgress = [[UISlider alloc]initWithFrame:CGRectMake(-2, WIDTH - 2, WIDTH+4, 2)];
    //  滑块左侧颜色
    self.playableProgress.minimumTrackTintColor = [UIColor redColor];
    //  滑块右侧颜色
    self.playableProgress.maximumTrackTintColor = [UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:0.5];
    
    UIImage *thumbImageEmp = [[UIImage alloc]init];
    [self.playableProgress setThumbImage:thumbImageEmp forState:UIControlStateNormal];
    [self.playableProgress setThumbImage:thumbImageEmp forState:UIControlStateSelected];
    self.playableProgress.userInteractionEnabled = NO;
    [self.playView addSubview:self.playableProgress];
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(DurationAvailablePlay) name:MPMovieDurationAvailableNotification object:self.moviePlayer];
    [notificationCenter addObserver:self selector:@selector(mediaPlayerPlaybackFinishedVideo) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
    self.showImageView = [NSHelper createrViewFrame:CGRectMake(WIDTH/2 - 30, WIDTH/2 - 30, 60, 60) backColor:@"FFFFFF"];
    self.showImageView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"btn_zy_spbf"]];
    [self.playView addSubview:self.showImageView];
    self.playView.userInteractionEnabled = YES;
    self.showImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapPlayShow = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playStartMove)];
    [self.showImageView addGestureRecognizer:tapPlayShow];
    [self.playView addGestureRecognizer:tapPlayShow];
    UIButton *remove = [NSHelper createButton:CGRectMake(WIDTH - 40, 26, 32, 32) title:nil unSelectImage:[UIImage imageNamed:@"btn_zy_close"] selectImage:nil target:self selector:@selector(removeBtnAction:)];
    [self.playView addSubview:remove];
    
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    if (reachability.currentReachabilityStatus == ReachableViaWWAN){
        [[[CommonUIAlert alloc] init] showCommonAlertView:self title:nil message:@"您当前正在使用移动网络,继续播放将消耗流量" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
            [self.moviePlayer pause];
            self.showImageView.hidden = NO;
        } confirm:^{
            [self.moviePlayer play];
            self.showImageView.hidden = YES;
            [self updateVideoPlayNumber];
        }];
    }else if (reachability.currentReachabilityStatus == NotReachable){
        [[[CommonUIAlert alloc] init] showCommonAlertView:self title:nil message:@"当前网络无连接,请检查网络连接" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
            [self.moviePlayer pause];
            self.showImageView.hidden = NO;
        } confirm:^{
            [self.moviePlayer pause];
            self.showImageView.hidden = NO;
        }];
    }else{
        [self.moviePlayer play];
        self.showImageView.hidden = YES;
         [self updateVideoPlayNumber];
    }
}

- (void)playStartMove{
    if (self.moviePlayer.playbackState ==MPMoviePlaybackStatePlaying) {
        [self.moviePlayer pause];
        self.showImageView.hidden = NO;
    }else{
        if(self.playableProgress.value == 1) {
            [self DurationAvailablePlay];
        }
        [self.moviePlayer play];
        self.showImageView.hidden = YES;
    }
}
//结束播放
- (void)mediaPlayerPlaybackFinishedVideo{
    self.playableProgress.value = 1;
    [self.timer invalidate];
    
}
//开始定时器
- (void)DurationAvailablePlay {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(refreshCurrentTime) userInfo:nil repeats:YES];
}
//定时器，播放进度
- (void)refreshCurrentTime {
    self.playableProgress.value = self.moviePlayer.currentPlaybackTime / self.moviePlayer.duration;
}

#pragma mark -------- 视频播发完成
-(void)movieFinishedCallback:(NSNotification*)notify {
    self.showImageView.hidden = NO;
    [self.timer invalidate];
}

- (void)removeBtnAction:(UIButton *)removeBtn{
    [self.moviePlayer stop];
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.3;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1.0)]];
    //    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    //    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    animation.values = values;
   
    [self.playView.layer addAnimation:animation forKey:nil];
    [UIView animateWithDuration:0.3 animations:^{
       
    } completion:^(BOOL finished) {
        self.moviePlayer = nil;
        self.playableProgress = nil;
        [self.timer invalidate];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.playView removeFromSuperview];
    }];
}

#pragma mark -------  关注TA
- (void)attentionBtnAction{
    //诸葛监控
    if (!self.isMyHomePage) {
        [[AppDelegate shareInstance] setZhugeTrack:@"关注用户" properties:@{@"useID":self.userID, @"company":[CommonMethod paramStringIsNull:self.taModel.company],@"position":[CommonMethod paramStringIsNull:self.taModel.position],@"address":self.taModel.city,@"goodAt":[[CommonMethod paramArrayIsNull:self.taModel.business]componentsJoinedByString:@","],@"industry":[CommonMethod paramStringIsNull:self.taModel.industry]}];
    }

    [self attentionBtnAction:[NSString stringWithFormat:@"%@",[DataModelInstance shareInstance].userModel.userId] other:[NSString stringWithFormat:@"%@",self.userID] type:YES];
    @weakify(self);
    self.attentionBtnActionSuccess = ^(){
        @strongify(self);
        self.taModel.isattention = [NSNumber numberWithInteger:1];
            NSLog(@"%ld",self.taModel.attentionhenum.integerValue);
        self.taModel.attentionhenum = [NSNumber numberWithInteger:(self.taModel.attentionhenum.integerValue + 1)];
        [self cretaerTabViewHeaderImage];
        [self.tableView reloadData];
        if(self.attentUser){
            self.attentUser(YES);
        }
    };
}

#pragma mark -------  取消关注TA
- (void)cancleAttentionBtnAction{
    [self attentionBtnAction:[NSString stringWithFormat:@"%@",[DataModelInstance shareInstance].userModel.userId] other:[NSString stringWithFormat:@"%@",self.userID] type:NO];
    @weakify(self);
    self.attentionBtnActionSuccess = ^(){
        @strongify(self);
        self.taModel.isattention = [NSNumber numberWithInteger:0];
        NSLog(@"%ld",self.taModel.attentionhenum.integerValue);
         self.taModel.attentionhenum = [NSNumber numberWithInteger:(self.taModel.attentionhenum.integerValue - 1)];
        [self cretaerTabViewHeaderImage];
        [self.tableView reloadData];
        if(self.attentUser){
            self.attentUser(NO);
        }
    };
}

#pragma mark --------- 弹出分享
- (void)sharViewFriends{
    //诸葛监控

    if (!self.isMyHomePage) {
        [[AppDelegate shareInstance] setZhugeTrack:@"分享用户" properties:@{@"useID":self.userID, @"company":[CommonMethod paramStringIsNull:self.taModel.company],@"position":[CommonMethod paramStringIsNull:self.taModel.position],@"address":self.taModel.city,@"goodAt":[[CommonMethod paramArrayIsNull:self.taModel.business]componentsJoinedByString:@","],@"industry":[CommonMethod paramStringIsNull:self.taModel.industry]}];
    }

    if (self.isMyHomePage) {
        ShareNormalView *shareView = [CommonMethod getViewFromNib:NSStringFromClass([ShareNormalView class])];
        shareView.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        [shareView setCopylink];
        @weakify(self);
        shareView.shareIndex = ^(NSInteger index){
            @strongify(self);
            if(index==2){
                 NSString *contentUrl = [NSString stringWithFormat:@"%@%@",ShareHomePageURL, self.userID];
                UIPasteboard *paste = [UIPasteboard generalPasteboard];
                [paste setString:contentUrl];
                [MBProgressHUD showSuccess:@"复制成功" toView:self.view];
            }else{
                [self firendClick:index];

            }
        };
        [[UIApplication sharedApplication].keyWindow addSubview:shareView];
        [shareView showShareNormalView];
        
    }else{
        self.coverView = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, HEIGHT ) backColor:@"41464E"];
        self.coverView.backgroundColor = [UIColor colorWithRed:65.0/255.0 green:70.0/255.0 blue:78.0/255 alpha:0.7];
        self.coverView.userInteractionEnabled = YES;
        UITapGestureRecognizer *cancleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancleCoveView)];
        [self.coverView addGestureRecognizer:cancleTap];
        
        [self.view addSubview:self.coverView];
        self.shawView = [[ShareView alloc]init];
        self.shawView.frame = CGRectMake(0, HEIGHT, WIDTH, HEIGHT - WIDTH * 0.46);
        [ self.shawView createrShareView];
        [self.view addSubview:self.shawView];
        [UIView animateWithDuration:0.3 animations:^{
            self.shawView.frame = CGRectMake(0, HEIGHT - WIDTH * 0.46, WIDTH, WIDTH * 0.46);
        } completion:^(BOOL finished) {
        }];
        __weak typeof(self) shareSlef = self;
        [self.shawView setShowShareViewIndex:^(NSInteger index){
            [shareSlef shareFriends:index];
        }];
    }
}

#pragma mark -------  添加好友
- (void)addFriendBtnnAction{
    if(![CommonMethod getUserCanAddFriend]){
        CompleteUserInfoView *completeUserInfoView = [[CompleteUserInfoView alloc] initWithType:CompleteUserInfoViewType_AddFriend];
        completeUserInfoView.completeUserInfoViewEditInfo = ^(){
            EditPersonalInfoViewController *vc = [[EditPersonalInfoViewController alloc] init];
            vc.savePersonalInfoSuccess = ^{
            };
            [self.navigationController pushViewController:vc animated:YES];
        };
        return;
    }
     [[AppDelegate shareInstance] setZhugeTrack:@"好友申请" properties:@{@"useID":self.userID, @"company":[CommonMethod paramStringIsNull:self.taModel.company],@"position":[CommonMethod paramStringIsNull:self.taModel.position],@"address":self.taModel.city,@"goodAt":[[CommonMethod paramArrayIsNull:self.taModel.business]componentsJoinedByString:@","],@"industry":[CommonMethod paramStringIsNull:self.taModel.industry]}];
    _isPresentVC = YES;
    NewAddFriendController *add = [[NewAddFriendController alloc]init];
    add.userID = self.userID;
    add.realname = self.taModel.realname;
    [self.navigationController pushViewController:add animated:YES];
}

#pragma mark -------  删除好友
- (void)delFriendBtnnAction{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"解除关系..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@", [DataModelInstance shareInstance].userModel.userId,self.userID] forKey:@"param"];
    
    [self requstType:RequestType_Delete apiName:API_NAME_USER_DEL_DELFRIENDS paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            weakSelf.taModel.isfriend = [NSNumber numberWithInteger:1];
            
            EMCmdMessageBody *body = [[EMCmdMessageBody alloc] initWithAction:[NSString stringWithFormat:@"%@",[DataModelInstance shareInstance].userModel.realname]];
            NSString *from = [[EMClient sharedClient] currentUsername];
            NSString *to = [NSString stringWithFormat:@"%@",self.userID];
            NSDictionary *ext = @{@"NSDictionary":@"NSDictionary"};
            // 生成message
            EMMessage *message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:body ext:ext];
            message.chatType = EMChatTypeChat;// 设置为单聊消息
            [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *aError) {
            }];
            
            //删除会话
            [[EMClient sharedClient].chatManager deleteConversation:[NSString stringWithFormat:@"%@",self.userID] isDeleteMessages:YES completion:nil];
            
            [MBProgressHUD showSuccess:@"好友已删除" toView:weakSelf.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

//弹出下拉菜单
- (MenuView *)menuView{
    if (!_menuView) {
        NSArray *dataArray;
        NSDictionary *dict1 = @{@"itemName" : @"推荐给朋友"};
        if(self.isMyHomePage){
            NSDictionary *dict2 = @{@"itemName" : @"编辑"};
            dataArray = @[dict2,dict1];
        }else{
            NSString *str;
            if (self.taModel.isattention.integerValue == 1) {
                str = @"取消关注";
            }else{
                str = @"关注Ta";
            }
            NSDictionary *dict2 = @{@"itemName" : str};
            NSString *str1;
            if (self.taModel.isfriend.integerValue == 1) {
                str1 = @"删除好友";
            }else{
                str1 = @"加好友";
            }
            NSDictionary *dict3 = @{@"itemName" : str1};
            dataArray = @[dict1,dict2,dict3];
        }
        CGFloat x = self.view.bounds.size.width / 3 * 2 - 15;
        CGFloat y = 66+7;
        CGFloat width = self.view.bounds.size.width * 0.3 + 20;
        CGFloat height = dataArray.count * 40;
        __weak __typeof(&*self)weakSelf = self;
        
        _menuView = [MenuView createMenuWithFrame:CGRectMake(x, y, width, height) target:self dataArray:dataArray itemsClickBlock:^(NSString *str, NSInteger tag) {
            [weakSelf doSomething:(NSString *)str tag:(NSInteger)tag];
        } backViewTap:^{
            weakSelf.flag = YES;
            _menuView = nil;
        }];
    }
    return _menuView;
}

#pragma mark ----- 下拉菜单点击事件
- (void)doSomething:(NSString *)str tag:(NSInteger)tag{
    if(self.isMyHomePage){
        if(tag == 1) {
            if (self.isMyHomePage) {
                ShareNormalView *shareView = [CommonMethod getViewFromNib:NSStringFromClass([ShareNormalView class])];
                shareView.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
                @weakify(self);
                shareView.shareIndex = ^(NSInteger index){
                    @strongify(self);
                    if (index == 2) {
                        index = 3;
                    }
                    [self firendClick:index];
                };
                [[UIApplication sharedApplication].keyWindow addSubview:shareView];
                [shareView showShareNormalView];
            }
        }else if (tag == 0) {
            [self editInfoBtnAction];
        }
    }else{
        if (tag == 0) {
            self.coverView = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, HEIGHT ) backColor:@"41464E"];
            self.coverView.backgroundColor = [UIColor colorWithRed:65.0/255.0 green:70.0/255.0 blue:78.0/255 alpha:0.7];
            self.coverView.userInteractionEnabled = YES;
            UITapGestureRecognizer *cancleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancleCoveView)];
            [self.coverView addGestureRecognizer:cancleTap];
            
            [self.view addSubview:self.coverView];
            self.shawView = [[ShareView alloc]init];
            self.shawView.frame = CGRectMake(0, HEIGHT, WIDTH, HEIGHT - WIDTH * 0.46);
            [ self.shawView createrShareView];
            [self.view addSubview:self.shawView];
            [UIView animateWithDuration:0.3 animations:^{
                self.shawView.frame = CGRectMake(0, HEIGHT - WIDTH * 0.46, WIDTH, WIDTH * 0.46);
            } completion:^(BOOL finished) {
            }];
            __weak typeof(self) shareSlef = self;
            [self.shawView setShowShareViewIndex:^(NSInteger index){
                [shareSlef shareFriends:index];
            }];
            
        }else if (tag == 1) {
            if (self.taModel.isattention.integerValue == 1) {
                //取消关注
                [self cancleAttentionBtnAction];
            }else{
                //关注TA
                [self attentionBtnAction];
            }
        }else if (tag == 2) {
            if (self.taModel.isfriend.integerValue == 1) {
                //删除好友";
                [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"是否确定删除好友？" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
                } confirm:^{
                    [self delFriendBtnnAction];
                }];
            }else{
                //@"加好友";
                [self addFriendBtnnAction];
            }
        }
    }
    self.flag = YES;
    [self.menuView showMenuWithAnimation:NO];
    self.menuView = nil;
}

#pragma mark -------- 分享页面
- (void)shareFriends:(NSInteger)index{
    [UIView animateWithDuration:0.3 animations:^{
        self.shawView.frame = CGRectMake(0, HEIGHT, WIDTH, WIDTH * 0.46);
        [self.coverView removeFromSuperview];
    } completion:^(BOOL finished) {
    }];
    [self firendClick:index];
}

#pragma mark ----------分享 ---
- (void)firendClick:(NSInteger )index{
    NSString *html = [NSString stringWithFormat:@"%@%@｜%@｜%@｜%@", self.taModel.company, self.taModel.position, self.taModel.realname, self.taModel.city, self.taModel.workyearstr];
    NSString *title = @"推荐你到“3号圈”认识Ta";
    if (self.isMyHomePage) {
        title = @"我的“3号圈”主页";
    }
    NSString *content = html.length>100?[html substringToIndex:100]:html;
    NSString *imageUrl = self.taModel.image;
    NSString *contentUrl = [NSString stringWithFormat:@"%@%@",ShareHomePageURL, self.userID];
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
            title = [NSString stringWithFormat:@"%@的“3号圈”主页", self.taModel.realname];
            if (self.isMyHomePage) {
                title = @"我的“3号圈”主页";
            }
            [self shareUMengWeiXInTitle:title count:content url:contentUrl image:imageSource index:index];break;
        }
        case 2:{
            ChoiceFriendViewController *choseCtr = [CommonMethod getVCFromNib:[ChoiceFriendViewController class]];
            choseCtr.nameCatergoryStr = [NSString stringWithFormat:@"%@｜%@｜%@", self.taModel.realname,self.taModel.city, self.taModel.workyearstr];
            choseCtr.userID = self.userID;
            choseCtr.position = [NSString stringWithFormat:@"%@%@",self.taModel.company,self.taModel.position];
            choseCtr.imagUrl =self.taModel.image;
            choseCtr.isSendCard = YES;
            NSString *goodAtStr;
            if (self.taModel.business.count>0) {
                for (int i = 0; i < self.taModel.business.count; i++) {
                    if (i == 0) {
                        goodAtStr  = [NSString stringWithFormat:@"#%@#", self.taModel.business[i]];
                    }else{
                        goodAtStr = [NSString stringWithFormat:@"%@ #%@#",goodAtStr,self.taModel.business[i]];
                    }
                }
                choseCtr.gooAtStr = goodAtStr;
            }
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
    }else if (index == 1) {
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
        if (!error) {
            [self updateUserSharNumber];
        }
        if (error) {
            NSLog(@"************Share fail with error %@*********",error);
        }else{
            NSLog(@"response data is %@",data);
        }
    }];
}

#pragma mark ------ 分享取消按钮
- (void)cancleCoveView{
    [UIView animateWithDuration:0.3 animations:^{
        if (self.showPhoneView) {
            self.showPhoneView.frame = CGRectMake(0,HEIGHT, WIDTH, self.phoneHeigth);
        }
        if (self.shawView) {
            self.shawView.frame = CGRectMake(0, HEIGHT, WIDTH, WIDTH * 0.46);
        }
        
        [self.coverView removeFromSuperview];
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark -- UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (!self.loadAllover) {
        return 0;
    }else if(self.netWorkStat == YES){
        return 1;
    }else if(self.taModel == nil){
        return 0;
    }else if(section == 1){
        if(self.isMyHomePage) {
            return 1;
        }else{
            if(self.taModel.business.count == 0) {
                return 0;
            }
        }
    }else if(section == 2){
        if(self.dymodel.dynamic_id.integerValue > 0) {
            return 1;
        }else{
                return 0;
        }
    }else if(section == 4) {
        if(self.isMyHomePage){
            return 1;
        }else{
            if(self.coffModel.count.integerValue == 0) {
                return 0;
            }
        }
    }else if(section == 5) {
        if (self.subModel.image.length == 0) {
            return 0;
        }
    }else if (section == 6){
        if (self.topicModel.sid.integerValue == 0 && self.topicModel.srid.integerValue == 0) {
            return 0;
        }
        
    }else if(section == 8){
        return self.workArray.count;
    }else if (section == 9){
        return self.lookArray.count;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (!self.loadAllover) {
        return 0;
    }else if(self.netWorkStat == YES){
        return 1;
    }else if (self.lookArray.count > 0) {
        return 10;
    }else{
        return 9;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }else if (section == 1 && self.taModel.business.count == 0){
        return 0;
    }else if(section == 2){
        if(self.dymodel.dynamic_id.integerValue <= 0) {
            return 0;
        }else{
            return 5;
        }
    }else if (section == 4 && (!self.isMyHomePage && self.coffModel.count.integerValue == 0)) {
        return 0;
    }else if (section == 5 && self.subModel.image.length == 0) {
        return 0;
    }else if (section == 6 &&self.topicModel.sid.integerValue == 0 && self.topicModel.srid.integerValue == 0 ){
            return 0;
    }else if (section == 8) {
        return 0;
    }else if (section == 9) {
        return 52;
    }else{
        return 5;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 5)];
    view.backgroundColor = [UIColor colorWithHexString:@"EFEFF4"];
    if (section == 9) {
        view.backgroundColor = [UIColor whiteColor];
        view.frame = CGRectMake(0, 0, WIDTH, 52);
        UILabel *label = [UILabel createrLabelframe:CGRectMake(0, 0, WIDTH, 5) backColor:[UIColor colorWithHexString:@"EFEFF4"] textColor:[UIColor clearColor] test:nil font:0 number:0 nstextLocat:NSTextAlignmentLeft];
        [view addSubview:label];
        UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(18, 22, WIDTH- 18, 14) backColor:[UIColor whiteColor] textColor:[UIColor colorWithHexString:@"818C9E"] test:@"看过Ta的人还看了" font:14.0 number:0 nstextLocat:NSTextAlignmentLeft];
        if (self.isMyHomePage) {
            titleLabel.textColor = HEX_COLOR(@"41464E");
            titleLabel.text = @"近期访客";
        }
        [view addSubview:titleLabel];
        UIView *lineView = [NSHelper createrViewFrame:CGRectMake(0, 52 - 0.5, WIDTH, 0.5) backColor:@"d9d9d9"];
        [view addSubview:lineView];
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES){
        return self.tableView.frame.size.height;
    }//公司职位
    if (indexPath.section == 0){
        return [MyMessageCell backHeigthTaMessageModel:self.taModel];
    }//擅长业务
    if (indexPath.section == 1){
        if (self.isMyHomePage) {
            return 109;
        }else if (self.taModel.business.count == 0) {
            return 0;
        }
        return 109;
    } if (indexPath.section == 2) {
        return   self.dymodel.cellHeight - 30;
    }//Ta的人脉
    if (indexPath.section == 3) {
        if (self.popleModel.count.integerValue == 0) {
            return 96;
        }
        return 124;
    } //人脉咖啡
    if (indexPath.section == 4){
        if (self.coffModel.count.integerValue == 0) {
            return 96;
        }
        return 124;
    }//专栏
    if (indexPath.section == 5){
        return 293;
    }if (indexPath.section == 6){
        return [MyHomeTopicCell backMyHomeTopicCellHeigthMyTopicModel:self.topicModel];
    }
    //个人简介
    if (indexPath.section == 7){
        if (self.workArray.count == 0) {
            return [VideoCell videoHeigthTaMessageModel:self.taModel]+5;
        }
        return [VideoCell videoHeigthTaMessageModel:self.taModel];
    }//工作经历
    if (indexPath.section == 8){
          self.workModel = self.workArray[indexPath.row];
        return  [WorkHistoryCell workHistoryCellModel:self.workModel];
//        return 124;
    }//看Ta的用户
    if (indexPath.section == 9){
        return 74;
    }
    return 109;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat){
        static NSString *cellID = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([NONetWorkTableViewCell class])];
        }
        self.tableView.tableHeaderView = [UIView new];
        return cell;
    }else{
        static NSString *cellID = @"cellID";
        //个人信息
        if (indexPath.section == 0){
            MyMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [CommonMethod getViewFromNib:NSStringFromClass([MyMessageCell class])];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.attestationDelegate = self;
            [cell tranferMyMessageTaMessageModel:self.taModel];
            UIView *lineView = [NSHelper createrViewFrame:CGRectMake(0, [MyMessageCell backHeigthTaMessageModel:self.taModel] - 0.5, WIDTH, 0.5) backColor:@"d9d9d9"];
            [cell.contentView addSubview:lineView];
            return cell;
        }//擅长业务
        else if (indexPath.section == 1){
            GooAtCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [CommonMethod getViewFromNib:NSStringFromClass([GooAtCell class])];
            }
            cell.gooAtCellDelegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell tranferGoodAt:self.taModel];
            UIView *lineView = [NSHelper createrViewFrame:CGRectMake(0,109 - 0.5, WIDTH , 0.5) backColor:@"d9d9d9"];
            [cell.contentView addSubview:lineView];
            return cell;
            
        }else if ( indexPath.section == 2){
            static NSString *cellID = @"MyDynamicCell";
            MyDynamicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            cell = [[MyDynamicCell alloc] initWithDataDict:self.dymodel isHome:self.isMyHomePage];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor whiteColor];
            return cell;
        }//人脉
        else if ( indexPath.section == 3){
            CofferCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [CommonMethod getViewFromNib:NSStringFromClass([CofferCell class])];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell tranferModeVale:indexPath.section cofferModel:self.coffModel peopleModel:self.popleModel isMyHomePage:self.isMyHomePage taModel:self.taModel];
            return cell;
        }//人脉咖啡
        else if (indexPath.section == 4){
            CofferCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [CommonMethod getViewFromNib:NSStringFromClass([CofferCell class])];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell tranferModeVale:indexPath.section cofferModel:self.coffModel peopleModel:self.popleModel isMyHomePage:self.isMyHomePage taModel:self.taModel];
            return cell;
        }//专访
        else if (indexPath.section == 5){
            static NSString *cellReID = @"cellReID";
            SubjectInterviewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReID];
            if (!cell) {
                cell = [CommonMethod getViewFromNib:NSStringFromClass([SubjectInterviewCell class])];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (self.subModel.image > 0) {
                UIView *lineView = [NSHelper createrViewFrame:CGRectMake(0,293 - 0.5, WIDTH , 0.5) backColor:@"d9d9d9"];
                [cell.contentView addSubview:lineView];
            }
            [cell tranferSubjectInterview:self.subModel];
            return cell;
        }//个人介绍
        else if (indexPath.section == 6){
          
            static NSString *cellID = @"MyHomeTopicCell";
            MyHomeTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [CommonMethod getViewFromNib:NSStringFromClass([MyHomeTopicCell class])];
            }
       
           
         
            cell.selectionStyle = UITableViewCellAccessoryNone;
            cell.userID = self.userID;
            [cell tranferMyHomeTopicCellMyTopicModel:self.topicModel];
            
            return cell;
        }
        else if (indexPath.section == 7){
            static NSString *cellReID = @"cellReID";
            VideoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReID];
            if (!cell) {
                cell = [CommonMethod getViewFromNib:NSStringFromClass([VideoCell class])];
            }
            cell.videoDelegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell tranferVideoTaMessageModel:self.taModel workArray:self.workArray];
            return cell;
        }//工作经历
        else if (indexPath.section == 8){
            static NSString *cellReID = @"cellReID";
            WorkHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReID];
            if (!cell) {
                cell = [CommonMethod getViewFromNib:NSStringFromClass([WorkHistoryCell class])];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.Index = indexPath.row;
            self.workModel = self.workArray[indexPath.row];
            CGFloat heigth = [WorkHistoryCell workHistoryCellModel:self.workModel];
            UIView *lineView = [NSHelper createrViewFrame:CGRectMake(0,heigth - 0.5, WIDTH , 0.5) backColor:@"d9d9d9"];
            if (self.workArray.count > 0) {
                if (self.workArray.count - 1 == indexPath.row) {
                    [cell.contentView addSubview:lineView];
                    
                }
            }
            [cell workHistoryCellModel:self.workModel];
            return cell;
        }//最近访问
        else if (indexPath.section == 9){
            static NSString *cellReID = @"cellReID";
            LookHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReID];
            if (!cell) {
                cell = [CommonMethod getViewFromNib:NSStringFromClass([LookHistoryCell class])];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.isMyPage = YES;
            self.lookModel = self.lookArray[indexPath.row];
            [cell lookHistoryModel:self.lookModel];
            return cell;
        }
    }
      return nil;
}

#pragma mark ------ 关闭
- (void)leftButtonClicked:(UIButton*)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES){
        [self getTaMessageInformation];
        return;
    }
    if (indexPath.section == 3){//人脉
        if(self.isMyHomePage){
            MyConnectionsController *vc = [[MyConnectionsController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            TaContactsCtr *contacts = [[TaContactsCtr alloc]init];
            contacts.userID = self.userID;
            contacts.hisattentionnum = self.taModel.hisattentionnum;
            contacts.attentionhenum = self.taModel.attentionhenum ;
            contacts.comfriendnum = self.taModel.comfriendnum;
            contacts.friendnum = self.taModel.friendnum;
            [self.navigationController pushViewController:contacts animated:YES];
        }
    }else if(indexPath.section == 4){//人脉咖啡
        if(self.isMyHomePage){
            MyCofferViewController * myCoffeeVC= [[MyCofferViewController alloc]init];
            myCoffeeVC.showBackBtn = YES;
            [self.navigationController pushViewController:myCoffeeVC animated:YES];
        }else{
            WallCofferController *wall = [[WallCofferController alloc]init];
            wall.userID = self.userID;
            [self.navigationController pushViewController:wall animated:YES];
        }
    }else if(indexPath.section == 5) {//专访
    if([self.subModel.url hasPrefix:PostDetailURL]){
            self.subModel.url = [self.subModel.url substringFromIndex:[[NSString stringWithFormat:@"%@/",PostDetailURL] length]];
        }
        InformationDetailController *vc = [[InformationDetailController alloc] init];
        vc.postID = [NSNumber numberWithDouble:self.subModel.url.doubleValue];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.section == 8) {//工作经历
        self.workModel = self.workArray[indexPath.row];
        WorkHistoryController *workHistory = [[WorkHistoryController alloc]init];
        workHistory.workHistoryDetailChange = ^(BOOL isEdit, workHistryModel *model) {
            [self getTaMessageInformation];
        };
        workHistory.isMyPage = self.isMyHomePage;
        workHistory.isfriend = self.taModel.isfriend;
        workHistory.workModel = self.workModel;
        [self.navigationController pushViewController:workHistory animated:YES];
    }else if (indexPath.section == 9) {//最近访问
        MyHomepageController *myHome = [[MyHomepageController alloc]init];
        self.lookModel = self.lookArray[indexPath.row];
        myHome.userID = self.lookModel.userid;
        [self.navigationController pushViewController:myHome animated:YES];
    }
}

#pragma mark --- VideoCellDelegate
- (void)addFriandAply{
    [self addFriendBtnnAction];
}

#pragma mark - 更新用户分享次数
- (void)updateUserSharNumber{
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
      [requestDict setObject:[NSString stringWithFormat:@"/%@",self.userID] forKey:@"param"];
       [self requstType:RequestType_Get apiName:API_NAME_UP_SHARE_CNT paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

#pragma mark - 更新用户视频播放次数
- (void)updateVideoPlayNumber{
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:self.userID forKey:@"userid"];
    [self requstType:RequestType_Post apiName:API_NAME_USER_UP_VIDEO_PLAY paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

- (void)copyPlayVideoAction:(NSInteger)index{
    if (index == 0) {
        NSString *str = [NSString stringWithFormat:@"tel:%@",self.taModel.phone];
        UIWebView *callWebView = [[UIWebView alloc]init];
        [callWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
        [self.view addSubview:callWebView];//也可以不加到页面上
    }else if (index == 1) {
        [MBProgressHUD showSuccess:@"复制成功" toView:nil];
        NSString *contentUrl = [NSString stringWithFormat:@"%@",self.taModel.email];
        UIPasteboard *generalPasteBoard = [UIPasteboard generalPasteboard];
        [generalPasteBoard setString:contentUrl];
    }else if (index == 2) {
        [MBProgressHUD showSuccess:@"复制成功" toView:nil];
        NSString *contentUrl = [NSString stringWithFormat:@"%@",self.taModel.weixin];
        UIPasteboard *generalPasteBoard = [UIPasteboard generalPasteboard];
        [generalPasteBoard setString:contentUrl];
    }
}

#pragma mark -获取认证信息
- (void)createrIDStart{
    NSString *uid = [NSString stringWithFormat:@"%@",[DataModelInstance shareInstance].userModel.userId];
    
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@",uid]forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_MEMBER_GET_IDENTITYSTART_MYSELF paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        
        NSString *start = [NSString stringWithFormat:@"%@",responseObject[@"status"]];
        
        if ([start isEqualToString:@"1"]){
            NSDictionary *dic  = responseObject[@"data"];
            self.attestationStr = [NSString stringWithFormat:@"%@",dic[@"hasValidUser"]];
            if(self.taModel.hasValidUser.integerValue != self.attestationStr.integerValue){
                self.taModel.hasValidUser = [NSNumber numberWithInteger:self.attestationStr.integerValue];
                [self.tableView reloadData];
            }
            self.imageUrl = dic[@"authenti_image"];
            UserModel *model = [DataModelInstance shareInstance].userModel;
            model.authenti_image = self.imageUrl;
            model.hasValidUser = dic[@"hasValidUser"];
            [DataModelInstance shareInstance].userModel = model;
        }else{
            [MBProgressHUD showError:responseObject[@"msg"] toView:self.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        
    }];
}

#pragma  mark --------MyMessageCellDelegate
- (void)attestationIdentityMessage{
    if(![CommonMethod getUserCanIdentify]){
        CompleteUserInfoView *completeUserInfoView = [[CompleteUserInfoView alloc] initWithType:CompleteUserInfoViewType_Identify];
        completeUserInfoView.completeUserInfoViewEditInfo = ^(){
            EditPersonalInfoViewController *vc = [[EditPersonalInfoViewController alloc] init];
            vc.savePersonalInfoSuccess = ^{
                [self getTaMessageInformation];
            };
            [self.navigationController pushViewController:vc animated:YES];
        };
        return;
    }
    if ([self.attestationStr isEqualToString:@"0"]){
        IdentityController *vc = [CommonMethod getVCFromNib:[IdentityController class]];
        vc.rootTmpViewController = self;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([self.attestationStr isEqualToString:@"1"]){
        PassReviewController *vc = [CommonMethod getVCFromNib:[PassReviewController class]];
        vc.urlImage = self.imageUrl;
        vc.rootTmpViewController = self;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([self.attestationStr isEqualToString:@"2"]){
        ReviewController *vc = [CommonMethod getVCFromNib:[ReviewController class]];
        vc.urlImage = self.imageUrl;
        vc.rootTmpViewController = self;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        NotPassController *vc = [CommonMethod getVCFromNib:[NotPassController class]];
        vc.rootTmpViewController = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark ------  修改个性签名
- (void)mySingActionChange{
    _isPresentVC = YES;
    RichTextViewController *vc = [CommonMethod getVCFromNib:[RichTextViewController class]];
    vc.isPersonalDynamic = YES;
    vc.content = [DataModelInstance shareInstance].userModel.mystate;
    vc.savePersonalRemark = ^(NSString *mystate){
        UserModel *model = [DataModelInstance shareInstance].userModel;
        model.mystate = mystate;
        [DataModelInstance shareInstance].userModel = model;
        self.taModel.mystate = mystate;
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    };
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark ------- GooAtCellDelegate擅长业务点击
- (void)searchResultGoodAt:(NSInteger)index{
    SearchViewController *search = [[SearchViewController alloc]init];
    search.searchTitle = self.taModel.business[index];
    [self.navigationController pushViewController:search animated:YES];
}

#pragma mark ------- VideoCellDelegate擅长业务点击
- (void)eaditMyInduceAction{
    [self editInfoBtnAction];
}
@end
