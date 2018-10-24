//
//  BaseViewController.m
//  EnterpriseCommunication
//
//  Created by HuMengChi on 15/6/2.
//  Copyright (c) 2015年 hmc. All rights reserved.
//

#import "BaseViewController.h"
#import <MessageUI/MessageUI.h>
#import "MenuView.h"

@interface BaseViewController ()<MFMessageComposeViewControllerDelegate,UIGestureRecognizerDelegate>
@end

@implementation BaseViewController


- (void)setNavigationBar_kdefaultColor{
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UINavigationBar appearance] setTintColor:WHITE_COLOR];
    [[UINavigationBar appearance] setBarTintColor:kDefaultColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:WHITE_COLOR,NSFontAttributeName:FONT_SYSTEM_SIZE(17)}];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)setNavigationBar_white{
    [[UINavigationBar appearance] setBackgroundImage:kImageWithColor(WHITE_COLOR, CGRectMake(0, 0, WIDTH, 1)) forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:kImageWithColor(WHITE_COLOR, CGRectMake(0, 0, WIDTH, 1))];
    [[UINavigationBar appearance] setTintColor:HEX_COLOR(@"383838")];
    [[UINavigationBar appearance] setBarTintColor:WHITE_COLOR];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:HEX_COLOR(@"383838"),NSFontAttributeName:FONT_SYSTEM_SIZE(17)}];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setNavigationBar_kdefaultColor];
    [UIView setAnimationsEnabled:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initDefaultLeftNavbar];
    
    id target = self.navigationController.interactivePopGestureRecognizer.delegate;
    // 创建全屏滑动手势，调用系统自带滑动手势的target的action方法
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:@selector(handleNavigationTransition:)];
    // 设置手势代理，拦截手势触发
    pan.delegate = self;
    // 给导航控制器的view添加全屏滑动手势
    [self.view addGestureRecognizer:pan];
    // 禁止使用系统自带的滑动手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

// 作用：拦截手势触发
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    // 注意：只有非根控制器才有滑动返回功能，根控制器没有。
    // 判断导航控制器是否只有一个子控制器，如果只有一个子控制器，肯定是根控制器
    if (self.navigationController.childViewControllers.count == 1){
        // 表示用户在根控制器界面，就不需要触发滑动手势，
        return NO;
    }
    //向左滑动
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

- (void)handleNavigationTransition:(UIPanGestureRecognizer *)gestureRecognizer{
    
}

- (void)initSearchBar:(CGRect)frame {
    self.searchBar = [[UISearchBar alloc] initWithFrame:frame];
    self.searchBar.showsCancelButton = TRUE;
    self.searchBar.returnKeyType = UIReturnKeySearch;
    self.searchBar.enablesReturnKeyAutomatically = YES;
    self.searchBar.delegate = self;
    [self.searchBar setPlaceholder:@"关键字搜索"];
    [self.searchBar setSearchTextPositionAdjustment:UIOffsetMake(5, 0)];
    [self.searchBar setBackgroundColor:HEX_COLOR(@"E6E8EB")];
    [self.searchBar setBackgroundImage:kImageWithColor(HEX_COLOR(@"E6E8EB"), self.searchBar.bounds)];
    [self.searchBar setSearchFieldBackgroundImage:kImageWithName(@"searchBackground") forState:UIControlStateNormal];
    [self.searchBar setSearchFieldBackgroundImage:kImageWithName(@"searchBackground") forState:UIControlStateDisabled];
    
    [self.view addSubview:self.searchBar];
}

- (void)initTableView:(CGRect)frame{
    self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.tableView.backgroundColor = kTableViewBgColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)initGroupedTableView:(CGRect)frame{
    self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = kTableViewBgColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)initScrollView:(CGRect)rect {
    self.scrollView = [[UIScrollView alloc] initWithFrame:rect];
    
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setPagingEnabled:NO];
    
    [self.view addSubview:self.scrollView];
}

#pragma mark -- UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}


#pragma mark -- SearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
}

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    //短信导航
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:19],NSFontAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:kDefaultColor];

    switch (result) {
        case MessageComposeResultSent:
            //信息传送成功
            break;
        case MessageComposeResultFailed:
            //信息传送失败
            break;
        case MessageComposeResultCancelled:
            //信息被用户取消传送
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showMessageView:(NSArray *)phones title:(NSString *)title{
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    //短信导航
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:19],NSFontAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    [[UINavigationBar appearance] setTintColor:[UIColor blueColor]];
    [[UINavigationBar appearance] setBarTintColor:kBackgroundColorDefault];
    MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init];
    if( [MFMessageComposeViewController canSendText] ){
        controller.recipients = phones;
        controller.body = title;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:^{
            [hud hideAnimated:YES];
        }];
    }else{
        [hud hideAnimated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"该设备不支持短信功能" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}


#pragma mark -------  关注(取消)TA
- (void)attentionBtnAction:(NSString*)useID other:(NSString *)otherID type:(BOOL)type{
    //yes添加，no删除
    __weak typeof(self) weakSelf = self;
    NSString *str = type?@"关注中...":@"取消中...";
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:str toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:useID forKey:@"userid"];
    [requestDict setObject:otherID forKey:@"otherid"];
    NSString *apiType;
    if (type) {
        apiType = API_NAME_USER_GET_ADDATION;
    }else{
        apiType = API_NAME_USER_GET_CANCELATION;
    }
    [self requstType:RequestType_Post apiName:apiType paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if(weakSelf.attentionBtnActionSuccess){
               weakSelf.attentionBtnActionSuccess();
            }
            if (type) {
                [MBProgressHUD showSuccess:@"已关注" toView:self.view];
            }else{
                [MBProgressHUD showSuccess:@"已取消" toView:self.view];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark - 自定义导航栏（白底）
- (UILabel *)createCustomNavigationBar:(NSString*)title{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 64)];
    barView.backgroundColor = WHITE_COLOR;
    [self.view addSubview:barView];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 20, 44, 44);
    [backBtn setImage:kImageWithName(@"btn_tab_back") forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(customNavBackButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [barView addSubview:backBtn];
    
    UILabel *titleLabel = [UILabel createLabel:CGRectMake(64, 20, WIDTH-128, 44) font:FONT_SYSTEM_SIZE(17) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"383838") ];
    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [barView addSubview:titleLabel];
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 63.5, WIDTH, 0.5)];
    lineLabel.backgroundColor = kCellLineColor;
    [barView addSubview:lineLabel];
    return titleLabel;
}

- (void)customNavBackButtonClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateAllGroupUsersDB{
    for(EMGroup *group in [[EMClient sharedClient].groupManager getJoinedGroups]){
        [self updateGroupUsersDB:group occupants:group.occupants handler:^(BOOL result, NSMutableArray *dataArray) {
            
        }];
    }
}

- (void)updateGroupUsersDB:(EMGroup*)group occupants:(NSArray*)occupants handler:(void(^)(BOOL result, NSMutableArray *dataArray))handler{
    NSArray *array;
    if(group){
        array = [CommonMethod paramArrayIsNull:group.occupants];
    }else{
        array = [CommonMethod paramArrayIsNull:occupants];
    }
    if (array.count==0) {
        handler(YES, [NSMutableArray array]);
        return;
    }
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[array componentsJoinedByString:@","] forKey:@"userid"];
    [self requstType:RequestType_Post apiName:API_NAME_POST_CHECKUSER_HEADERANDNAME paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *tmpArray = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            NSMutableArray *userArray = [NSMutableArray array];
            for(NSDictionary *dict in tmpArray){
                GroupChartModel *model = [[GroupChartModel alloc] initWithDict:dict];
                [userArray addObject:model];
            }
            if(userArray.count){
                if(group){
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        UIImage *image = [UIImage createImageWithUserModelArray:userArray];
                        NSData *imageData = UIImagePNGRepresentation(image);
                        if([[NSFileManager defaultManager] fileExistsAtPath:SAVE_GROUP_HEADER_IMAGE(group.groupId)]){
                            [[NSFileManager defaultManager] removeItemAtPath:SAVE_GROUP_HEADER_IMAGE(group.groupId) error:nil];
                        }
                        [imageData writeToFile:SAVE_GROUP_HEADER_IMAGE(group.groupId) atomically:YES];
                        handler(YES, userArray);
                    });
                }else{
                    handler(YES, userArray);
                }
                [[DBInstance shareInstance] savGroupChartModelArray:userArray];
            }else{
                handler(YES, userArray);
            }
        }else{
            handler(YES, [NSMutableArray array]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        handler(NO, [NSMutableArray array]);
    }];
}

@end
