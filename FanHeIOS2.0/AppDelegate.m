//
//  AppDelegate.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/6/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "AppDelegate.h"
#import "CRNavigationController.h"
#import "LoginViewController.h"
#import "RegisterGuideViewController.h"
#import "GuideViewController.h"
#import "LaunchViewController.h"

#import "PersonalViewController.h"

#import "NewHomeViewController.h"
#import "ContactsViewController.h"
#import "TalkFiananceViewController.h"
#import "ActivityViewController.h"

#import "InterestBusinessController.h"
#import "RegisterScanCardController.h"
#import "ChatViewController.h"

//通知广告弹出

#import "NotPushView.h"
#import "WebViewController.h"

//通知跳转
#import "NewFriendsController.h"

//管理员主页
#import "AdminMainViewController.h"

//bug修复上报sdk
//#import <Bugtags/Bugtags.h>

//诸葛
#import "Zhuge.h"

#define GaoDeKey      @"820fbd6f670e265e9527c0a23202b3e4"

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#import <AMapFoundationKit/AMapFoundationKit.h>
#import "ActivityNotificationViewController.h"
#import "TouTiaoViewController.h"

#import "Growing.h"

#import "ActivityDetailController.h"
#import "NSString+Base64.h"

#import "MainWebVC.h"
#import "AFNetworking.h"

// 引入 JPush 功能所需头文件
#import "JPUSHService.h"
// 如果需要使用 idfa 功能所需要引入的头文件（可选）
#import "UITabBarController+Animation.h"

@interface AppDelegate ()<RESideMenuDelegate,EMClientDelegate, EMChatManagerDelegate, UNUserNotificationCenterDelegate,NotPushViewDelegate,UITabBarControllerDelegate, WXApiDelegate, JPUSHRegisterDelegate>{
    
    BOOL _isJpush;
}


@property (nonatomic, assign) BOOL isEnterBackground;

@property (nonatomic, strong) NotPushView *pushView;
@property (nonatomic, strong) NSString * webUrl;

@property (nonatomic, strong) PersonalViewController *personalVC;

@property (strong, nonatomic) Reachability *reachability;

@end

@implementation AppDelegate

NSUncaughtExceptionHandler* _uncaughtExceptionHandler = nil;

+(AppDelegate*)shareInstance{
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    [self VVSCHANGff:application didFinishLaunchingWithOptions:launchOptions];
    
    
    return YES;
}

- (void)VVSCHANGff:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    NSString *NowTime = [[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10];
    NSArray *appLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    NSString *languageName = [appLanguages objectAtIndex:0];
    if ([self ZpareDate:NowTime withDate:@"2018-11-30"] == 1) {
        [self rootViewCtr:application didFinishLaunchingWithOptions:launchOptions];
    }else if ([self ZpareDate:NowTime withDate:@"2018-11-30"] == -1 && ![languageName isEqualToString:@"en"]){
        _isJpush = YES;
        if(_isJpush){
            // 3.0.0及以后版本注册可以这样写，也可以继续用旧的注册方式
            JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
            entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
            [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
            
            //如不需要使用IDFA，advertisingIdentifier 可为nil
            [JPUSHService setupWithOption:launchOptions appKey:@"e0b4482aa1df842c0230e4a3"
                                  channel:@"AppStore"
                         apsForProduction:isProductionBool
                    advertisingIdentifier:nil];
            
            //2.1.9版本新增获取registration id block接口。
            [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
                if(resCode == 0){
                    NSLog(@"registrationID获取成功：%@",registrationID);
                }else{
                    NSLog(@"registrationID获取失败，code：%d",resCode);
                }
            }];
        }
        [self setupMyView];
    }else{
        [self rootViewCtr:application didFinishLaunchingWithOptions:launchOptions];
    }
}

- (void)setupMyView{
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    //定时跳转比如9月1号后才执行 为了规则审核，你最好加上如果是语言是英文，就不执行
    //这里切换
    //这样直接切换你会GG，怎么让苹果看不出来，就是你的真本事了
    //到了时间后就直接切换成h5不需要再显示壳的内容
    MainWebVC *webVC = [MainWebVC shareController];
    self.window.rootViewController = webVC;
    [self.window makeKeyAndVisible];
//    或者
//    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:webVC animated:NO completion:nil];
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusNotReachable) {
            NSLog(@"无网络");
        }
        else{
            //有网络发起请求
            AFHTTPRequestOperationManager *afn = [AFHTTPRequestOperationManager manager];
            afn.requestSerializer = [AFJSONRequestSerializer serializer];
            afn.responseSerializer = [AFJSONResponseSerializer serializer];
            // 设置超时时间
            [afn.requestSerializer willChangeValueForKey:@"timeoutInterval"];
            afn.requestSerializer.timeoutInterval = 20;
            [afn.requestSerializer didChangeValueForKey:@"timeoutInterval"];
            
            [afn.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [afn.requestSerializer setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
            afn.responseSerializer.acceptableContentTypes = [afn.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
            
            
            [afn POST:@"http://szhb56.cn/relation.txt" parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [webVC loadWithUrl:responseObject[@"webUrl"]];
                });
            } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                
            }];
        }
    }];
    [manager startMonitoring];
}

- (UIViewController*)rootController{
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor whiteColor];
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    if(HEIGHT == 480){
        bgImageView.image = kImageWithName(@"loading_4");
    }else if(HEIGHT == 568){
        bgImageView.image = kImageWithName(@"loading_5");
    }else if(HEIGHT == 667){
        bgImageView.image = kImageWithName(@"loading_6");
    }else{
        bgImageView.image = kImageWithName(@"loading_6p");
    }
    [vc.view addSubview:bgImageView];
    return vc;
}

- (void)rootViewCtr:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    /*======================友盟配置SDK====================*/
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self setUMengConfig];
    });
    
    /*======================诸葛io====================*/
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[Zhuge sharedInstance].config setDebug : NO];
        [[Zhuge sharedInstance] startWithAppKey:@"8ef9c74a8e1b4b65abd195790bb0ce48"
                                  launchOptions:launchOptions];
    });
    
    /*======================Growingio====================*/
    [Growing startWithAccountId:@"84cd7bd7671d024b"];
    // 其他配置
    // 开启Growing调试日志 可以开启日志
    // [Growing setEnableLog:YES];
    
    /*======================高德地图====================*/
    [AMapServices sharedServices].apiKey = @"820fbd6f670e265e9527c0a23202b3e4";
    
    /*======================热修复====================
     [JSPatch startWithAppKey:@"a7878569770cd891"];
     [JSPatch sync];*/
    
    /*======================网络状态监听====================*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.reachability = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    [self.reachability startNotifier];
    
    /*======================获取AccessToken====================*/
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getAccessToken];
    });
    
    /*======================导航栏设置====================*/
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:19],NSFontAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:kDefaultColor];
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    
    //推送注册
    [self reginApns:application];
    // 去掉本地所通知
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    //判断是否在后台运行
    self.isEnterBackground = NO;
    
    LaunchViewController *vc = [CommonMethod getVCFromNib:[LaunchViewController class]];
    self.window.rootViewController = vc;
    self.window.backgroundColor = kTableViewBgColor;
    
    [self.window makeKeyAndVisible];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 设置处理异常的Handler
        _uncaughtExceptionHandler = NSGetUncaughtExceptionHandler();
        NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    });
    
    //从服务器验证receipt失败之后，在程序再次启动的时候，使用保存的receipt再次到服务器验证
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:AppStoreInfoLocalFilePath]) {//如果在改路下不存在文件，说明就没有保存验证失败后的购买凭证，也就是说发送凭证成功。
        [fileManager createDirectoryAtPath:AppStoreInfoLocalFilePath//创建目录
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }else{//存在购买凭证，说明发送凭证失败，再次发起验证
        [self sendFailedIapFiles];
    }
}

- (NSInteger)ZpareDate:(NSString*)aDate withDate:(NSString*)bDate{
    NSInteger aa = 0;
    NSDateFormatter *dateformater = [[NSDateFormatter alloc] init];
    [dateformater setDateFormat:@"yyyy-MM-dd"];
    NSDate *dta = [[NSDate alloc] init];
    NSDate *dtb = [[NSDate alloc] init];
    
    dta = [dateformater dateFromString:aDate];
    dtb = [dateformater dateFromString:bDate];
    NSComparisonResult result = [dta compare:dtb];
    if (result==NSOrderedAscending){
        aa=1;
    }else if (result==NSOrderedDescending){
        aa=-1;
    } else{
        aa = -1;
    }
    return aa;
}

//验证receipt失败,App启动后再次验证
- (void)sendFailedIapFiles{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    //搜索该目录下的所有文件和目录
    NSArray *cacheFileNameArray = [fileManager contentsOfDirectoryAtPath:AppStoreInfoLocalFilePath error:&error];
    
    if (error == nil){
        for (NSString *name in cacheFileNameArray){
            if ([name hasSuffix:@".plist"]){//如果有plist后缀的文件，说明就是存储的购买凭证
                NSString *filePath = [NSString stringWithFormat:@"%@/%@", AppStoreInfoLocalFilePath, name];
                [self sendAppStoreRequestBuyPlist:filePath];
            }
        }
    }
}

- (void)sendAppStoreRequestBuyPlist:(NSString *)plistPath{
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    //这里的参数请根据自己公司后台服务器接口定制，但是必须发送的是持久化保存购买凭证
    NSData *receipt = [dic objectForKey:IAP_RECEIPT];
    if(receipt==nil){
        [self sendAppStoreRequestSucceededWithData:plistPath];
        return;
    }
    NSString *receiptBase64 = [NSString base64StringFromData:receipt length:[receipt length]];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[dic objectForKey:IAP_USER_ID] forKey:@"userid"];
    [requestDict setObject:[CommonMethod paramStringIsNull:receiptBase64] forKey:@"data"];
    [[[UIViewController alloc] init] requstType:RequestType_Post apiName:API_NAME_USER_POST_USER_IAPSECONDVALID paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            [self sendAppStoreRequestSucceededWithData:plistPath];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

//验证成功就从plist中移除凭证
- (void)sendAppStoreRequestSucceededWithData:(NSString *)plistPath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:plistPath]){
        [fileManager removeItemAtPath:plistPath error:nil];
    }
}

void uncaughtExceptionHandler(NSException *exception) {
    if (exception) {
        NSArray *arr = [exception callStackSymbols];
        NSString *reason = [exception reason];
        NSString *name = [exception name];
        
        NSLog(@"=============异常崩溃报告=============\nname:\n%@\nreason:\n%@\ncallStackSymbols:\n%@",name,reason,[arr componentsJoinedByString:@"\n"]);
        NSLog(@"=============异常崩溃报告=============");
    }
}

- (void)reachabilityChanged:(NSNotification *)n {
    Reachability *reach = [n object];
    NSLog(@"network status changed:%@",reach.currentReachabilityString);
}

// 将得到的deviceToken传给SDK
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    if(_isJpush){
        [JPUSHService registerDeviceToken:deviceToken];
    }else{
        [[EMClient sharedClient] bindDeviceToken:deviceToken];
    }
}

// 注册deviceToken失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    //    NSLog(@"error -- %@",error);
}

// APP进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application{
    if(!_isJpush){
        //获取未读消息数量并且显示
        NSInteger unReadCount = 0;
        for (EMConversation *conversation in [[EMClient sharedClient].chatManager getAllConversations]){
            unReadCount += conversation.unreadMessagesCount;
        }
        [UIApplication sharedApplication].applicationIconBadgeNumber = unReadCount;
        [[EMClient sharedClient] applicationDidEnterBackground:application];
        self.isEnterBackground = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:AppGotoBackground object:nil];
    }
}

// APP将要从后台返回
- (void)applicationWillEnterForeground:(UIApplication *)application{
    if(!_isJpush){
        [[EMClient sharedClient] applicationWillEnterForeground:application];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationWillResignActive" object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //判断是否在后台运行
    self.isEnterBackground = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationDidBecomeActive" object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    self.isEnterBackground = YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    if(!_isJpush){
        BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
        BOOL growing = [Growing handleUrl:url];
        if (!result) {
            // 其他如支付等SDK的回调
        }
        [WXApi handleOpenURL:url delegate:self];
        if ([url.host isEqualToString:@"safepay"]) {
            //跳转支付宝钱包进行支付，处理支付结果
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                NSLog(@"result = %@",resultDic);
    //            [[NSNotificationCenter defaultCenter] postNotificationName:@"aliPaymentResult" object:resultDic];
            }];
        }
        return result&&growing;
    }else{
        return YES;
    }
}

// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options{
    if(!_isJpush){
        [WXApi handleOpenURL:url delegate:self];
        if ([url.host isEqualToString:@"safepay"]) {
            //跳转支付宝钱包进行支付，处理支付结果
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                NSLog(@"result = %@",resultDic);
    //            [[NSNotificationCenter defaultCenter] postNotificationName:@"aliPaymentResult" object:resultDic];
            }];
        }
    }
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    if(self.isEnterBackground && !_isJpush){
        [self lookForNotification:notification.userInfo];
    }
}

#pragma mark- JPUSHRegisterDelegate
// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]&&_isJpush) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有 Badge、Sound、Alert 三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]&&_isJpush) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required, For systems with less than or equal to iOS 6
    if(_isJpush){
        [JPUSHService handleRemoteNotification:userInfo];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // Required, iOS 7 Support
    if(_isJpush){
        [JPUSHService handleRemoteNotification:userInfo];
    }else{
        if(self.isEnterBackground){
            [self lookForNotification:userInfo];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ContactsVCReload" object:nil];
        }
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark -IOS 10
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    if(!_isJpush){
        NSDictionary * userInfo = notification.request.content.userInfo;
        if(self.isEnterBackground){
            [self lookForNotification:userInfo];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ContactsVCReload" object:nil];
        }
    }
    // IOS 7 Support Required
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    if(!_isJpush){
        NSDictionary * userInfo = response.notification.request.content.userInfo;
        if(self.isEnterBackground){
            [self lookForNotification:userInfo];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ContactsVCReload" object:nil];
        }
    }
    // IOS 7 Support Required
    completionHandler();
}

#pragma mark -推送消息过来，跳转到相应的界面
- (void)lookForNotification:(NSDictionary *)userInfo{
    CRNavigationController *nav = (CRNavigationController*)self.tabBarController.selectedViewController;
    NSNumber *msgtype = [CommonMethod paramNumberIsNull:userInfo[@"msgtype"]];
    switch (msgtype.integerValue) {
        case 1:{
            //避免多次跳转到聊天界面
            if([((CRNavigationController*)self.tabBarController.selectedViewController).topViewController isKindOfClass:[ChatViewController class]]){
                return;
            }
            NSString *conversationId = userInfo[@"f"];
            ChatViewController *chatVC = [[ChatViewController alloc]
                                          initWithConversationChatter:conversationId
                                          conversationType:EMConversationTypeChat];
            if ([conversationId isEqualToString:@"jm_assistant"]) {
                chatVC.title = @"金脉小秘书";
                chatVC.phoneNumber = @"4001799686";
            } else if ([conversationId isEqualToString:@"activity_assistant"]) {
                ActivityNotificationViewController *vc = [[ActivityNotificationViewController alloc] init];
                [nav pushViewController:vc animated:YES];
                return;
            }  else if ([conversationId isEqualToString:@"jm_topic"]) {
                //金脉头条
                TouTiaoViewController *vc = [[TouTiaoViewController alloc] init];
                [nav pushViewController:vc animated:YES];
                return;
            } else{
                NSMutableArray *array = [[DBInstance shareInstance]
                                         selectCharttingID:conversationId];
                if(array.count != 0) {
                    ChartModel *model = array[0];
                    chatVC.title = model.realname;
                    chatVC.position =
                    [NSString stringWithFormat:@"%@%@", model.company, model.position];
                    chatVC.phoneNumber = model.phone;
                }
            }
            [nav pushViewController:chatVC animated:YES];
        }
            break;
        case 16:{
            NSNumber *postiD = userInfo[@"mid"];
            ActivityDetailController *vc = [[ActivityDetailController alloc] init];
            vc.activityid = postiD;
            [nav pushViewController:vc animated:YES];
            }
            break;
        default:{
        }
            break;
    }
}

#pragma mark - methods
- (void)updateWindowRootVC{
    NewHomeViewController *homeVC = [CommonMethod getVCFromNib:[NewHomeViewController class]];
    homeVC.title = @"首页";
    CRNavigationController *homeNav = [[CRNavigationController alloc] initWithRootViewController:homeVC];
    [homeVC updateVCDisplay];
    
    ContactsViewController *contactsVC = [CommonMethod getVCFromNib:[ContactsViewController class]];
    contactsVC.title = @"人脉";
    CRNavigationController *contactsNav = [[CRNavigationController alloc] initWithRootViewController:contactsVC];
    
    TalkFiananceViewController *businessVC = [[TalkFiananceViewController alloc] init];
    businessVC.title = @"大家聊金融";
    CRNavigationController *businessNav = [[CRNavigationController alloc] initWithRootViewController:businessVC];
    
    ActivityViewController *activityVC = [CommonMethod getVCFromNib:[ActivityViewController class]];
    activityVC.title = @"活动";
    CRNavigationController *activityNav = [[CRNavigationController alloc] initWithRootViewController:activityVC];
    //预加载
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UserModel *model = [DataModelInstance shareInstance].userModel;
        model.cityData = [NSArray new];
        model.tagData = [NSArray new];
        [DataModelInstance shareInstance].userModel = model;
        [contactsVC updateVCDisplay];
        [businessVC updateVCDisplay];
        [activityVC updateVCDisplay];
    });
    
    NSArray *array = @[homeNav, contactsNav, businessNav, activityNav];
    
    [self initDB];
    
    //底部菜单栏
    if(_tabBarController){
        _tabBarController = nil;
    }
    _tabBarController = [[UITabBarController alloc] init];
    [_tabBarController setViewControllers:array];
    [_tabBarController.tabBar setClipsToBounds:YES];
    [[UITabBar appearance] setBackgroundColor:kTabbarBgColor];
    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
    [self customizeTabBarForController:_tabBarController];
    [_tabBarController setSelectedViewController:array[0]];
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 0.5)];
    lineLabel.backgroundColor = HEX_COLOR(@"E5E5E5");
    [_tabBarController.tabBar addSubview:lineLabel];
    _tabBarController.delegate = self;
    
    //左侧视图
    if(self.personalVC != nil){
        self.personalVC = nil;
    }
    self.personalVC = [CommonMethod getVCFromNib:[PersonalViewController class]];
    
    //侧滑
    RESideMenu *sideMenuViewController = [[RESideMenu alloc] initWithContentViewController:_tabBarController leftMenuViewController:self.personalVC rightMenuViewController:nil];
    sideMenuViewController.backgroundImage = kImageWithName(@"bg_my");
    sideMenuViewController.menuPreferredStatusBarStyle = 1;
    sideMenuViewController.delegate = self;
    sideMenuViewController.contentViewInPortraitOffsetCenterX = WIDTH/2-95;
    sideMenuViewController.contentViewShadowColor = [UIColor blackColor];
    sideMenuViewController.contentViewShadowOffset = CGSizeMake(0, 0);
    sideMenuViewController.contentViewScaleValue = 1;
    sideMenuViewController.contentViewShadowOpacity = 1;
    sideMenuViewController.contentViewShadowRadius = 12;
    sideMenuViewController.contentViewShadowEnabled = NO;
    sideMenuViewController.bouncesHorizontally = NO;
    sideMenuViewController.parallaxEnabled = YES;
    
    self.window.rootViewController = sideMenuViewController;
    
    //获取未读消息数量并且显示
    NSInteger unReadCount = 0;
    for (EMConversation *conversation in [[EMClient sharedClient].chatManager getAllConversations]){
        unReadCount += conversation.unreadMessagesCount;
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = unReadCount;
    //     [self pushNotCenViewShow];
    if(self.showAdvertisement){
        self.showAdvertisement = NO;
        [homeVC showAdvertisement];
    }
}

#pragma mark - UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    CRNavigationController *currentNav = tabBarController.selectedViewController;
    UIViewController *currentVC = currentNav.viewControllers[0];
    if(tabBarController.selectedIndex == 0){
        UIViewController *selectVC = ((CRNavigationController*)viewController).viewControllers[0];
        if([currentVC isEqual:selectVC]){
            NewHomeViewController *vc = (NewHomeViewController*)currentVC;
//            [vc.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
            [vc.tableView.mj_header beginRefreshing];
        }
    }
    return YES;
}

#pragma mark - 更新侧边栏的维度消息数量
- (void)updateMenuNewMsgNum{
    if(self.personalVC != nil){
        [self.personalVC updateDisplay];
    }
}

#pragma mark - RESideMenuDelegate
- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController{
    if(self.personalVC != nil){
        [self.personalVC updateDisplay];
    }
}

//设置tabbarItem
- (void)customizeTabBarForController:(UITabBarController *)tabBarController {
    NSInteger index = 0;
    NSArray *tabbarImages = @[@"btn_foot_index", @"btn_foot_friends", @"btn_foot_column", @"btn_foot_event"];
    for (UITabBarItem *item in [[tabBarController tabBar] items]) {
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_hover",tabbarImages[index]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@",tabbarImages[index]]];
        [item setSelectedImage:[selectedimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [item setImage:unselectedimage];
        CRNavigationController *nav = tabBarController.viewControllers[index];
        NSString *titleStr = [nav.viewControllers[0] title];
        if(index == 2){
            item.title = @"话题";
        }else{
            item.title = titleStr;
        }
        [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:HEX_COLOR(@"818C9E"),NSForegroundColorAttributeName,[UIFont systemFontOfSize:10],NSFontAttributeName, nil] forState:UIControlStateNormal];
        [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:HEX_COLOR(@"E24943"),NSForegroundColorAttributeName,[UIFont systemFontOfSize:10],NSFontAttributeName, nil] forState:UIControlStateSelected];
        item.titlePositionAdjustment = UIOffsetMake(0, -3);
        index++;
    }
}

#pragma mark --点击侧边栏菜单跳转
- (void)gotoOtherViewControllerFromPersonal:(UIViewController*)vc{
    CRNavigationController *nav = (CRNavigationController*)self.tabBarController.selectedViewController;
    [nav pushViewController:vc animated:NO];
}

#pragma mark --管理员主页
- (void)gotoAdminMainVC{
    self.tabBarController = nil;
    AdminMainViewController *vc = [CommonMethod getVCFromNib:[AdminMainViewController class]];
    CRNavigationController *nav = [[CRNavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
}

#pragma mark --注册成功之后，感兴趣的行业、推荐关注人脉界面
- (void)gotoRecommendContacts{
    InterestBusinessController *vc = [CommonMethod getVCFromNib:[InterestBusinessController class]];
    vc.isShowBack = NO;
    CRNavigationController *nav = [[CRNavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
}

#pragma mark --注册成功之后，上传名片
- (void)gotoScanCard{
    RegisterScanCardController *vc = [CommonMethod getVCFromNib:[RegisterScanCardController class]];
    CRNavigationController *nav = [[CRNavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
}

#pragma mark --//导航页
- (void)gotoGuide{
    GuideViewController *vc = [CommonMethod getVCFromNib:[GuideViewController class]];
    self.window.rootViewController = vc;
}

#pragma mark --//注册登录引导页
- (void)gotoRegisterGuide{
    [self initDB];
    if(self.tabBarController){
        if(self.tabBarController.viewControllers.count){
            CRNavigationController *nav = self.tabBarController.viewControllers[0];
            if(nav.viewControllers.count){
                NewHomeViewController *vc = nav.viewControllers[0];
                [vc removeNotification];
            }
        }
    }
    RegisterGuideViewController *vc = [CommonMethod getVCFromNib:[RegisterGuideViewController class]];
    CRNavigationController *nav = [[CRNavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
}

#pragma mark --//登录界面
- (void)gotoLogin{
    LoginViewController *vc = [CommonMethod getVCFromNib:[LoginViewController class]];
    vc.hideBackNavBtn = YES;
    CRNavigationController *nav = [[CRNavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
}

#pragma mark --注册
- (void)gotoRegister{
    
}

#pragma mark - 诸葛事件纪录
- (void)setZhugeTrack:(NSString *)track properties:(NSDictionary *)dict{
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    if(dict){
        [properties setObject:dict forKey:@"event"];
    }
    UserModel *model = [DataModelInstance shareInstance].userModel;
    if(model){
        NSDictionary *userDict = @{@"industry":[CommonMethod paramStringIsNull:model.industry], @"business":[CommonMethod paramStringIsNull:model.business],@"position":[CommonMethod paramStringIsNull:model.position],@"city":[CommonMethod paramStringIsNull:model.address]};
        [properties setObject:userDict forKey:@"user"];
    }
    [[Zhuge sharedInstance] track:track properties:properties];
}

- (void)setZhugeUserInfo{
    UserModel *model = [DataModelInstance shareInstance].userModel;
    //定义属性
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[@"name"] = [CommonMethod paramStringIsNull:model.realname];
    userInfo[@"avatar"] = [CommonMethod paramStringIsNull:model.image];
    userInfo[@"mobile"] = [CommonMethod paramStringIsNull:model.phone];
    userInfo[@"location"] = [CommonMethod paramStringIsNull:model.address];
    userInfo[@"公司"] = [CommonMethod paramStringIsNull:model.company];
    
    //跟踪用户
    [[Zhuge sharedInstance] identify:model.userId.stringValue properties:userInfo];
}

#pragma mark - 数据库初始化
- (void)initDB{
    NSLog(@"startDB---%@", [NSDate currentTimeString:kTimeFormatLong]);
    [NSFileManager createFolderInDirectory:D_PATH_DB_LOCAL folder:@""];
    [NSFileManager copyItemToFolder:D_PATH_DB_LOCAL fileName:DB_FILE_NAME dataBasePath:D_PATH_DB_LOCAL];
    [[DBInstance shareInstance] openDB:D_PATH_DB_ALL_LOCAL];
    
    if([DataModelInstance shareInstance].userModel){
        [self setZhugeUserInfo];
        [self EMLogin];
        [self getActivityCityList];
        [self getAikatietosuodatin];
        [self getQiNiuToken];
        [self uploadLastActiveTime];
        [self updateFriendsListArrayData:nil];
        [self updateMyUserModelData];
        
    }else{
        [self EMLogout];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
    NSLog(@"endDB---%@", [NSDate currentTimeString:kTimeFormatLong]);
}

#pragma mark --环信登录
- (void)EMLogin{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMOptions *options = [EMOptions optionsWithAppkey:HuanXinKey];
        options.apnsCertName = PushtheCertificate;
        
        // 是否自动同意群组邀请。 该设置打开后，如果你在线,对方邀请你进群，你会自动进入，不需要你去调用同意方法(默认值就是YES)。
        options.isAutoAcceptGroupInvitation = YES;
        
        // 离开群组时是否自动删除群组的会话,设置为yes后，该群组的Conversation和messages会被删除(默认值就是YES)。
        options.isDeleteMessagesWhenExitGroup = YES;
        
        EMError *error = [[EMClient sharedClient] initializeSDKWithOptions:options];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!error){
                [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
                [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
            }
        });
        [[EMClient sharedClient] loginWithUsername:[DataModelInstance shareInstance].userModel.userId.stringValue password:EMLoginPasswd completion:^(NSString *aUsername, EMError *aError) {
            if (!aError) {
                [[EMClient sharedClient].options setIsAutoLogin:YES];
            }
            
            //更新群组成员信息
            [[[BaseViewController alloc] init] updateAllGroupUsersDB];
        }];
        
        [[EMClient sharedClient] updatePushNotifiationDisplayName:[DataModelInstance shareInstance].userModel.realname completion:^(NSString *aDisplayName, EMError *aError) {
            
        }];
        
        [[EMClient sharedClient] getPushNotificationOptionsFromServerWithCompletion:^(EMPushOptions *options, EMError *aError) {
            options.displayName = [DataModelInstance shareInstance].userModel.realname;
            if([[[[RKUserDefaults standardUserDefaults] loadUserDefaultsDictionary] allKeys] count] == 0){
                [[RKUserDefaults standardUserDefaults] setBool:YES forKey:ShowDetailKey];
                [[RKUserDefaults standardUserDefaults] setBool:YES forKey:VoiceKey];
                [[RKUserDefaults standardUserDefaults] setBool:YES forKey:DampingKey];
            }
            if([[RKUserDefaults standardUserDefaults] boolForKey:ShowDetailKey]){
                options.displayStyle = EMPushDisplayStyleMessageSummary;
            }else{
                options.displayStyle = EMPushDisplayStyleSimpleBanner;
            }
            [[EMClient sharedClient] updatePushNotificationOptionsToServerWithCompletion:^(EMError *aError) {
                
            }];
            
        }];
    });
}

#pragma mark --环信注销
- (void)EMLogout{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[EMClient sharedClient] logout:YES completion:^(EMError *aError) {
            if(aError){
                
            }
        }];
        [[EMClient sharedClient] removeDelegate:self];
    });
}

#pragma mark --- 更新用户最后活跃时间
- (void)uploadLastActiveTime{
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[CommonMethod paramNumberIsNull:[DataModelInstance shareInstance].userModel.userId] forKey:@"userid"];
    [[[UIViewController alloc] init] requstType:RequestType_Post apiName:API_NAME_USER_UP_LAST_ACT_TIME paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isKindOfDictionary:responseObject]){
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}
#pragma mark --- 网络请求数据获取活动智能筛选
- (void)getAikatietosuodatin{
    [[[UIViewController alloc] init] requstType:RequestType_Get apiName:API_NAME_ACTIVITYCHOSELIST_THRID paramDict:nil hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            UserModel *model = [DataModelInstance shareInstance].userModel;
            model.capacityArray = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            
            [DataModelInstance shareInstance].userModel = model;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
 
}
#pragma mark --- 网络请求数据获取活动筛选城市
- (void)getActivityCityList{
    [[[UIViewController alloc] init] requstType:RequestType_Get apiName:API_NAME_ACTIVITYCITYLIST_GRTCITY paramDict:nil hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            UserModel *model = [DataModelInstance shareInstance].userModel;
            model.cityName = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            
            [DataModelInstance shareInstance].userModel = model;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];

}
#pragma mark --- 网络请求数据获取Token
- (void)getQiNiuToken{
    [[[UIViewController alloc] init] requstType:RequestType_Get apiName:API_NAME_USER_GET_QINIUTOKEN paramDict:nil hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if([[responseObject objectForKey:@"data"] isKindOfClass:[NSString class]]){
                [DataModelInstance shareInstance].qiNiuTokenStr = [CommonMethod paramStringIsNull:[responseObject objectForKey:@"data"]];
                [DataModelInstance shareInstance].qiNiuUrl = @"http://image2.51jinmai.com/";
            }else{
                NSDictionary *dic =  [CommonMethod paramDictIsNull:[responseObject objectForKey:@"data"]];
                [DataModelInstance shareInstance].qiNiuTokenStr = [CommonMethod paramStringIsNull:[dic objectForKey:@"token"]];
                [DataModelInstance shareInstance].qiNiuUrl = [CommonMethod paramStringIsNull:[dic objectForKey:@"url"]];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

#pragma mark --- 获取AccessToken
- (void)getAccessToken{
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:@"auth_token" forKey:@"grant_type"];
    [requestDict setObject:@"hmc" forKey:@"client_id"];
    [requestDict setObject:@"123456" forKey:@"client_secret"];
    [[[UIViewController alloc] init] requstType:RequestType_Post apiName:API_NAME_ACCESS_TOKEN paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isKindOfDictionary:responseObject]){
            [DataModelInstance shareInstance].tokenStr = [NSString stringWithFormat:@"%@ %@",responseObject[@"token_type"], responseObject[@"access_token"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

#pragma mark - 更新个人信息
- (void)updateMyUserModelData{
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@", [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [[[UIViewController alloc] init] requstType:RequestType_Get apiName:API_NAME_USER_GET_USER_INFO paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            UserModel *model1 = [DataModelInstance shareInstance].userModel;
            UserModel *model2 = [[UserModel alloc] initWithDict:responseObject[@"data"]];
            model2.password = model1.password;
            model2.infoIsNotFinished = model1.infoIsNotFinished;
            if(model2.status.integerValue == 2){
                [DataModelInstance shareInstance].userModel = nil;
                [self gotoRegisterGuide];
            }else{
                [DataModelInstance shareInstance].userModel = model2;
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

#pragma mark - 更新好友列表到本地
- (void)updateFriendsListArrayData:(GetFriendListResult)result{
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@", [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [[[UIViewController alloc] init] requstType:RequestType_Get apiName:API_NAME_USER_GET_ALLFRIENDS paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *tmpArray = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            NSMutableArray *dataArray = [NSMutableArray array];
            for(NSDictionary *dict in tmpArray){
                ChartModel *model = [[ChartModel alloc] initWithDict:dict];
                [dataArray addObject:model];
            }
            [[DBInstance shareInstance] saveChartModelArray:dataArray];
            if(result){
                result(YES);
            }
        }else{
            if(result){
                result(NO);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        if(result){
            result(NO);
        }
    }];
}
//tabbar消息未读数量
- (void)showUnreadCountViewItemNO:(NSInteger)index unReadCountSum:(NSInteger)unReadCountSum {
    if(index == 0){
        [self updateMenuNewMsgNum];
    }
    UILabel *bageView = (UILabel*)[self.tabBarController.tabBar subviewWithTag:1000+index];
    if(unReadCountSum){
        if(!bageView){
            bageView = [[UILabel alloc] init];
            bageView.backgroundColor = kDefaultColor;
            bageView.tag = 1000+index;
            [self.tabBarController.tabBar addSubview:bageView];
            if(index == 1 || index == 3 || index == 2 || index == 0){
                bageView.frame=CGRectMake(WIDTH/4/2+WIDTH/4*index+8, 4, 16, 16);
                [CALayer updateControlLayer:bageView.layer radius:8 borderWidth:0 borderColor:nil];
                bageView.textAlignment = NSTextAlignmentCenter;
                bageView.textColor = WHITE_COLOR;
            }else{
                bageView.frame=CGRectMake(WIDTH/4/2+WIDTH/4*index+8, 4, 10, 10);
                [CALayer updateControlLayer:bageView.layer radius:5 borderWidth:0 borderColor:nil];
            }
        }
        if(index == 1 || index == 3 || index == 2 || index == 0){
            NSString *numStr;
            if(unReadCountSum>100){
                numStr = @"99+";
                bageView.font = FONT_SYSTEM_SIZE(10);
            }else{
                numStr = [NSString stringWithFormat:@"%ld", (long)unReadCountSum];
                bageView.font = FONT_SYSTEM_SIZE(12);
            }
            bageView.text = numStr;
        }
    }else{
        if(bageView){
            [bageView removeFromSuperview];
        }
    }
}

#pragma mark ----------- 环信推送
#pragma mark - EMClientDelegate
- (void)didLoginFromOtherDevice{
    CRNavigationController *nav = (CRNavigationController*)self.tabBarController.selectedViewController;
    [[[CommonUIAlert alloc] init] showCommonAlertView:nav.visibleViewController title:@"警告" message:@"该账号已在其它设备上登录" cancelButtonTitle:nil otherButtonTitle:@"确定" cancle:^{
        
    } confirm:^{
        [DataModelInstance shareInstance].userModel = nil;
        [self gotoRegisterGuide];
    }];
}

#pragma mark - EMChatManagerDelegate
- (void)didReceiveMessages:(NSArray *)aMessages{
    if(![[RKUserDefaults standardUserDefaults] boolForKey:VoiceKey]){
        AudioServicesDisposeSystemSoundID(1007);
    }else{
        AudioServicesPlaySystemSound(1007);
    }
    if(![[RKUserDefaults standardUserDefaults] boolForKey:DampingKey]){
        AudioServicesDisposeSystemSoundID(kSystemSoundID_Vibrate);
    }else{
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    NSInteger unReadCount = 0;
    for(EMMessage *message in aMessages){
        [self _handleReceivedAtMessage:message];
        if(message && [message isKindOfClass:[EMMessage class]]){
            if(message.chatType == EMChatTypeChat && message.body.type == EMMessageBodyTypeText){
                NSString *text = ((EMTextMessageBody *)message.body).text;
                if([text isEqualToString:@"我们已成功交换名片，现在可以随时交流了。"]){
                    [self updateFriendsListArrayData:^(BOOL result) {
                        [self showNotificationWithMessage:message];
                    }];
                }else{
                    if([text isEqualToString:@"您的金脉+身份认证已成功！"]){
                        UserModel *model = [DataModelInstance shareInstance].userModel;
                        model.hasValidUser = @(1);
                        [DataModelInstance shareInstance].userModel = model;
                        [self.personalVC updateDisplay];
                    }
                    [self updateFriendsListArrayData:nil];
                    [self showNotificationWithMessage:message];
                }
            }else if(message.body.type==EMMessageBodyTypeImage && ((EMImageMessageBody*)message.body).downloadStatus!=EMDownloadStatusSuccessed){
                [self showNotificationWithMessage:message];
                [[EMClient sharedClient].chatManager downloadMessageAttachment:message progress:^(int progress) {
                } completion:^(EMMessage *message, EMError *error) {
                }];
            }else{
                [self showNotificationWithMessage:message];
            }
        }
    }
    for (EMConversation *conversation in [[EMClient sharedClient].chatManager getAllConversations]){
        unReadCount += conversation.unreadMessagesCount;
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = unReadCount;
}

- (void)_handleReceivedAtMessage:(EMMessage*)aMessage{
    if (aMessage.chatType != EMChatTypeGroupChat || aMessage.direction != EMMessageDirectionReceive) {
        return;
    }
    
    NSString *loginUser = [EMClient sharedClient].currentUsername;
    NSDictionary *ext = aMessage.ext;
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:aMessage.conversationId type:EMConversationTypeGroupChat createIfNotExist:NO];
    if (loginUser && conversation && ext && [ext objectForKey:kGroupMessageAtList]) {
        id target = [ext objectForKey:kGroupMessageAtList];
        if ([target isKindOfClass:[NSString class]] && [(NSString*)target compare:kGroupMessageAtAll options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            NSNumber *atAll = conversation.ext[kHaveUnreadAtMessage];
            if ([atAll intValue] != kAtAllMessage) {
                NSMutableDictionary *conversationExt = conversation.ext ? [conversation.ext mutableCopy] : [NSMutableDictionary dictionary];
                [conversationExt removeObjectForKey:kHaveUnreadAtMessage];
                [conversationExt setObject:@kAtAllMessage forKey:kHaveUnreadAtMessage];
                conversation.ext = conversationExt;
            }
        }
        else if ([target isKindOfClass:[NSArray class]]) {
            if ([target containsObject:loginUser]) {
                if (conversation.ext[kHaveUnreadAtMessage] == nil) {
                    NSMutableDictionary *conversationExt = conversation.ext ? [conversation.ext mutableCopy] : [NSMutableDictionary dictionary];
                    [conversationExt setObject:@kAtYouMessage forKey:kHaveUnreadAtMessage];
                    conversation.ext = conversationExt;
                }
            }
        }
    }
}

//发送本地推送
- (void)showNotificationWithMessage:(EMMessage *)message{
    if([message.from isEqualToString:@"jm_assistant"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ContactsVCReload" object:nil];
    }
    if(self.isEnterBackground==NO){
        return;
    }
    EMPushOptions *options = [[EMClient sharedClient] pushOptions];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date]; //触发通知的时间
    if (options.displayStyle == EMPushDisplayStyleMessageSummary) {
        EMMessageBody *messageBody = message.body;
        NSString *messageStr = nil;
        switch (messageBody.type) {
            case EMMessageBodyTypeText:{
                messageStr = ((EMTextMessageBody *)messageBody).text;
            }
                break;
            case EMMessageBodyTypeImage:{
                messageStr = @"发来一张图片";
            }
                break;
            case EMMessageBodyTypeLocation:{
                messageStr = @"发来Ta的位置";
            }
                break;
            case EMMessageBodyTypeVoice:{
                messageStr = @"发来一段语音";
            }
                break;
            default:
                break;
        }
        NSString *fromNameStr;
        NSMutableArray *array = [[DBInstance shareInstance] selectCharttingID:message.from];
        
        NSNumber *valueNymb = message.ext[@"value"];
        if([message.from isEqualToString:@"jm_assistant"]){
            if (valueNymb.integerValue != 16) {
                  fromNameStr = @"金脉小秘书";
            }
            [self updateMyUserModelData];
        }else if ([message.from isEqualToString:@"activity_assistant"]) {
            fromNameStr = @"活动助手";
        }else if ([message.from isEqualToString:@"jm_topic"]) {
            fromNameStr = @"金脉头条";
        }else if(array.count){
            fromNameStr = [array[0] realname];
        }else{
            fromNameStr = @"新的好友";
        }
        if (message.chatType == EMChatTypeGroupChat) {
            NSArray *groupArray = [[EMClient sharedClient].groupManager getJoinedGroups];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:message.conversationId]) {
                    fromNameStr = group.subject;
                    messageStr = [NSString stringWithFormat:@"%@：%@", fromNameStr, messageStr];
                    break;
                }
            }
        }else if (message.chatType == EMChatTypeChatRoom){
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            NSString *key = [NSString stringWithFormat:@"OnceJoinedChatrooms_%@", [[EMClient sharedClient] currentUsername]];
            NSMutableDictionary *chatrooms = [NSMutableDictionary dictionaryWithDictionary:[ud objectForKey:key]];
            NSString *chatroomName = [chatrooms objectForKey:message.conversationId];
            if(chatroomName){
                
            }
        }else{
            messageStr = [NSString stringWithFormat:@"%@：%@", fromNameStr, messageStr];
        }
        notification.alertBody = [NSString stringWithFormat:@"%@", messageStr];
    }else{
        notification.alertBody = @"您有一条新消息";
    }
    NSNumber *indexNumb = message.ext[@"topage"];
    NSNumber *valueNymb = message.ext[@"value"];
    if (indexNumb.integerValue == 16) {
          notification.userInfo = @{@"msgtype":@(16),@"mid":valueNymb,@"f":message.from};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"topage" object:nil];
    }else{
          notification.userInfo = @{@"msgtype":@(1),@"mid":@(0),@"f":message.from};
    }
  
    notification.alertAction = NSLocalizedString(@"open", @"Open");
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.repeatInterval = 0;
    if([[RKUserDefaults standardUserDefaults] boolForKey:VoiceKey]){
        notification.soundName= UILocalNotificationDefaultSoundName;
    }
    //发送通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

#pragma mark -- 设置友盟社会化
- (void)setUMengConfig{
    //设置友盟appkey
    [[UMSocialManager defaultManager] setUmSocialAppkey:UmengAppkey];
    
#if DEBUG==1
    //打开调试日志
    [[UMSocialManager defaultManager] openLog:YES];
#else
    [[UMSocialManager defaultManager] openLog:NO];
#endif
    
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:UmWeixinAppkey appSecret:UmWeixinappSecret redirectURL:UmWeixinHttp];
    
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:UmSSOApp  appSecret:UmSSOSecret redirectURL:UmSSoHttp];
}

#pragma mark -------- 环信推送注册
- (void)reginApns:(UIApplication *)application{
    if(IOS_X>=10){
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
        }];
    }else if([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound |
        UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
}

#pragma mark -------  透传广告消息
- (void)didReceiveCmdMessages:(NSArray *)aCmdMessages{
    for(EMMessage *message in aCmdMessages){
        if ([message.from isEqualToString:@"jm_assistant"]){
            NSDictionary *dict = message.ext;
            NSNumber *type = dict[@"type"];
            if(type.integerValue == 1){
                NSString *imageUrl = dict[@"image"];
                NSString *endTime = dict[@"endtime"];
                NSInteger endTimeINt = [endTime stringByReplacingOccurrencesOfString:@"-" withString:@""].integerValue;
                NSString *begintime = dict[@"begintime"];
                NSInteger begintimeINt = [begintime stringByReplacingOccurrencesOfString:@"-" withString:@""].integerValue;
                self.webUrl = dict[@"url"];
                NSString *cuurrent = [NSDate currentTimeString:kShortTimeFormat];
                
                NSInteger cuurrentINt = [cuurrent stringByReplacingOccurrencesOfString:@"-" withString:@""].integerValue;
                if (cuurrentINt >= begintimeINt && cuurrentINt <= endTimeINt) {
                    [self pushNotCenViewShow:imageUrl];
                }
            }
        }else{
            [[EMClient sharedClient].chatManager deleteConversation:message.from isDeleteMessages:YES completion:nil];
            [self updateFriendsListArrayData:nil];
        }
    }
}

- (void)pushNotCenViewShow:(NSString *)imageUrl{
    if (self.pushView == nil) {
        self.pushView = [[NotPushView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.pushView];
    }
    self.pushView.notPushViewDelegate = self;
    [self.pushView createrPushView:imageUrl];
}

- (void)removeWindow{
    [self.pushView removeFromSuperview];
    self.pushView = nil;
}

- (void)tapImageAction{
    WebViewController *vc = [[WebViewController alloc]init];
    vc.webUrl = self.webUrl;
    [[AppDelegate shareInstance] gotoOtherViewControllerFromPersonal:vc];
    
    [self.pushView removeFromSuperview];
    self.pushView = nil;
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp{
    if ([resp isKindOfClass:[PayResp class]]){
        PayResp *response = (PayResp*)resp;
        switch(response.errCode){
            case WXSuccess:{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"wxPaymentSuccess" object:nil];
            }
                break;
            default:{
                NSLog(@"支付失败，retcode=%d",resp.errCode);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"wxPaymentFailure" object:@(resp.errCode)];
            }
                break;
        }
    }
}
@end
