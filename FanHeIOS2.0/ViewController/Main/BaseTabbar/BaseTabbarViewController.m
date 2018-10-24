//
//  BaseTabbarViewController.m
//  JinMai
//
//  Created by 胡梦驰 on 16/3/24.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import "BaseTabbarViewController.h"
#import "SearchViewController.h"
#import "GetMyselfCoffer.h"
#import "WebViewController.h"
#import "ScanQRCodeViewController.h"
#import "JionQRcodeGroupViewController.h"

@interface BaseTabbarViewController ()<ScanQRCodeViewControllerDelegate,EMChatManagerDelegate>

@property (nonatomic, strong) UIButton *personalBtn;

@end

@implementation BaseTabbarViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    
    self.navigationController.navigationBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.tabBarController.tabBar.hidden = NO;
    [self getMessagesCount];
    //个人信息
    [[AppDelegate shareInstance] updateMyUserModelData];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.sideMenuViewController.panGestureEnabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.sideMenuViewController.panGestureEnabled = NO;
    self.hidesBottomBarWhenPushed = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    UIView *tabbarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 64)];
    tabbarView.backgroundColor = kDefaultColor;
    tabbarView.tag = 3000;
    [self.view addSubview:tabbarView];
    
    self.personalBtn = [self intNavBarButtonItem:NO frame:CGRectMake(0, 20, 60, 40) imageName:@"btn_my_white" buttonName:nil];
    
    
    [self intNavBarButtonItem:YES frame:CGRectMake(0, 0, 80, 64) imageName:@"btn_sweep_white" buttonName:nil];
    
    [self getMessagesCount];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteUserNewMsg) name:DeleteUserNewMsg object:nil];
}

- (void)deleteUserNewMsg{
    [self.personalBtn setImage:kImageWithName(@"btn_my_white") forState:UIControlStateNormal];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 二维码扫描，扫一扫
- (void)scanQRCode{
    [self rightButtonClicked:nil];
}

- (void)rightButtonClicked:(id)sender {
    [self newThreadForAvoidButtonRepeatClick:sender];
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if(granted){
            dispatch_async(dispatch_get_main_queue(), ^{
                ScanQRCodeViewController *vc = [[ScanQRCodeViewController alloc] init];
                vc.delegate = self;
                [self.navigationController pushViewController:vc animated:YES];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] setStatusBarHidden:NO];
            });
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"扫码需访问相机" message:@"请在iPhone的“设置>隐私>相机”选项中，允许3号圈访问你的相机" cancelButtonTitle:@"取消" otherButtonTitle:@"设置" cancle:^{
            } confirm:^{
                if(IOS_X >= 10){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }else{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy"]];
                }
            }];
        }
    }];
}

#pragma mark - ScanQRCodeViewControllerDelegate
- (void)ScanQRCodeViewControllerDelegateResult:(NSString *)symbolsStr{
    NSLog(@"----%@",symbolsStr);
    if([symbolsStr hasPrefix:CoffeeQRCodeURL]){
        symbolsStr = [symbolsStr substringFromIndex:[CoffeeQRCodeURL length]];
    }else if([symbolsStr hasPrefix:GroupURL]){
        symbolsStr = [symbolsStr substringFromIndex:[ShareHomePageURL length]];
        JionQRcodeGroupViewController *myhome = [[JionQRcodeGroupViewController alloc] init];
        myhome.groupID = symbolsStr;
        [self.navigationController pushViewController:myhome animated:YES];
        return;
    }else if([symbolsStr hasPrefix:ShareHomePageURL]){
        symbolsStr = [symbolsStr substringFromIndex:[ShareHomePageURL length]];
        NewMyHomePageController *myhome = [[NewMyHomePageController alloc] init];
        myhome.userId = @(symbolsStr.integerValue);
        [self.navigationController pushViewController:myhome animated:YES];
        return;
    }else{
        if([CommonMethod paramStringIsNull:symbolsStr]){
            WebViewController *vc = [[WebViewController alloc] init];
            vc.webUrl = symbolsStr;
            vc.customTitle = @"详情";
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            [MBProgressHUD showError:@"无法识别二维码" toView:self.view];
        }
        return;
    }
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@", @(symbolsStr.integerValue), [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_USER_GET_COFFEE_INTRO paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            ZbarCoffeeModel *model = [[ZbarCoffeeModel alloc] initWithDict:[responseObject objectForKey:@"data"]];
            if (model.rst.integerValue == 5) {
                GetMyselfCoffer *view = [CommonMethod getViewFromNib:@"GetMyselfCoffer"];
                view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
                [view ceraterTitleLabelShow:YES];
                [[UIApplication sharedApplication].keyWindow addSubview:view];
            }else{
                NewMyHomePageController *myhome = [[NewMyHomePageController alloc] init];
                myhome.userId = model.userid;
                myhome.zbarModel = model;
                [self.navigationController pushViewController:myhome animated:YES];
            }
        }else{
            [MBProgressHUD showError:@"此咖啡无效" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

- (void)zbarDidStopWithError:(NSError *)error {
    if(error){
        NSLog(@"二维码扫描失败: %@",error);
    }
}

#pragma mark - method
- (void)leftButtonClicked:(UIButton*)sender{
    [self presentLeftMenuViewController:sender];
    if(self.leftButtonClicked){
        self.leftButtonClicked();
    }
}

#pragma mark - 获取新消息数量
- (void)getMessagesCount{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[NSString stringWithFormat:@"/%@",[DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_USER_NEW_MSG_COUNT paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            NSDictionary *dict = [responseObject objectForKey:@"data"];
            //人脉
            NSNumber *cardrequest = [dict objectForKey:@"cardrequest"];
            NSNumber *attention = [dict objectForKey:@"attention"];
            //话题
            NSNumber *notecount = [dict objectForKey:@"notecount"];
            NSNumber *vpcount = [dict objectForKey:@"vpcount"];
            //活动
            NSNumber *newapplycount = [dict objectForKey:@"newapplycount"];
            NSNumber *newaskcount = [dict objectForKey:@"newaskcount"];
            //人脉咖啡
            NSNumber *getcoffeecount = [dict objectForKey:@"getcoffeecount"];
            NSNumber *replycoffeecount = [dict objectForKey:@"replycoffeecount"];
            //动态数量
            NSNumber *dynamiccount = [dict objectForKey:@"dynotecount"];
            //任务数量
            NSNumber *taskcount = [dict objectForKey:@"taskcount"];
            if([weakSelf getUnReadNewMsgNumber] || attention.integerValue || vpcount.integerValue || notecount.integerValue || newaskcount.integerValue || newapplycount.integerValue || taskcount.integerValue){
                [weakSelf.personalBtn setImage:kImageWithName(@"btn_my_white_hover") forState:UIControlStateNormal];
            }else{
                [weakSelf.personalBtn setImage:kImageWithName(@"btn_my_white") forState:UIControlStateNormal];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:DeleteUserNewMsg object:nil];
                });
            }
            [[AppDelegate shareInstance] showUnreadCountViewItemNO:0 unReadCountSum:dynamiccount.integerValue];
            [[AppDelegate shareInstance] showUnreadCountViewItemNO:1 unReadCountSum:cardrequest.integerValue+replycoffeecount.integerValue+getcoffeecount.integerValue];
            [[AppDelegate shareInstance] showUnreadCountViewItemNO:2 unReadCountSum:notecount.integerValue];
            //            [[AppDelegate shareInstance] showUnreadCountViewItemNO:3 unReadCountSum:newaskcount.integerValue+newapplycount.integerValue];
            if(weakSelf.cardRequestBlock){
                weakSelf.cardRequestBlock(cardrequest);
            }
            if(weakSelf.tfNoteRequestBlock){
                weakSelf.tfNoteRequestBlock(notecount);
            }
            if(weakSelf.coffeeRequestBlock){
                weakSelf.coffeeRequestBlock(@(replycoffeecount.integerValue+getcoffeecount.integerValue));
            }
            if(weakSelf.dynamicRequestBlock){
                weakSelf.dynamicRequestBlock(dynamiccount);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

#pragma mark - 未读消息数量
- (NSInteger)getUnReadNewMsgNumber{
    NSInteger unReadCount = 0;
    for (EMConversation *conversation in [[EMClient sharedClient].chatManager getAllConversations]){
        unReadCount += conversation.unreadMessagesCount;
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = unReadCount;
    return unReadCount;
}

#pragma mark - EMChatManagerDelegate
- (void)didReceiveMessages:(NSArray *)aMessages{
    [self.personalBtn setImage:kImageWithName(@"btn_my_white_hover") forState:UIControlStateNormal];
    [self getMessagesCount];
}

#pragma mark -------  透传广告消息
- (void)didReceiveCmdMessages:(NSArray *)aCmdMessages{
    for(EMMessage *message in aCmdMessages){
        if ([message.from isEqualToString:@"jm_assistant"]){
            NSDictionary *dict = message.ext;
            NSNumber *type = dict[@"type"];
            if(type.integerValue == 2){
                [self getMessagesCount];
            }
        }
    }
}
@end
