//
//  LaunchViewController.m
//  JinMai
//
//  Created by 胡梦驰 on 16/6/1.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import "LaunchViewController.h"

@interface LaunchViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;

@end

@implementation LaunchViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //移除滑动手势
    for (UIPanGestureRecognizer *ges in self.view.gestureRecognizers){
        [self.view removeGestureRecognizer:ges];
    }
    if(HEIGHT == 480){
        self.bgImageView.image = kImageWithName(@"loading_4");
    }else if(HEIGHT == 568){
        self.bgImageView.image = kImageWithName(@"loading_5");
    }else if(HEIGHT == 667){
        self.bgImageView.image = kImageWithName(@"loading_6");
    }else{
        self.bgImageView.image = kImageWithName(@"loading_6p");
    }
    [UIView animateWithDuration:2.f animations:^{
        self.bgImageView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        //判断是否是第一次启动应用
        if(![[NSUserDefaults standardUserDefaults] boolForKey:NOT_FIRST_LAUNCH]){
            [[RKUserDefaults standardUserDefaults] setBool:YES forKey:ShowDetailKey];
            [[RKUserDefaults standardUserDefaults] setBool:YES forKey:VoiceKey];
            [[RKUserDefaults standardUserDefaults] setBool:YES forKey:DampingKey];
            [[AppDelegate shareInstance] gotoGuide];
        }else{
            if([DataModelInstance shareInstance].adminUserModel && [CommonMethod paramNumberIsNull:[DataModelInstance shareInstance].adminUserModel.userid].integerValue){
                [[AppDelegate shareInstance] gotoAdminMainVC];
            }else if([DataModelInstance shareInstance].userModel && [CommonMethod paramNumberIsNull:[DataModelInstance shareInstance].userModel.userId].integerValue){
//                [[AppDelegate shareInstance] gotoRecommendContacts];
//                return ;
                [self loadHttpAdvertisementData];
            }else{
                [NSThread sleepForTimeInterval:3.0];
                [[AppDelegate shareInstance] gotoRegisterGuide];
            }
        }
    }];
    // Do any additional setup after loading the view.
}

- (void)loadHttpAdvertisementData{
    [self requstType:RequestType_Get apiName:API_NAME_GET_LOGIN_ADVERT paramDict:nil hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if(responseObject[@"data"] && [CommonMethod paramNumberIsNull:responseObject[@"data"][@"ispreview"]].integerValue==0){
                [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"data"] forKey:LOGIN_ADVERTISEMENT_DATA];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_ADVERTISEMENT_DATA];
        if(dict&&[NSDate daysAwayFromToday:[NSDate dateFromString:dict[@"begintime"] format:kShortTimeFormat]]<=0&&[NSDate daysAwayFromToday:[NSDate dateFromString:dict[@"endtime"] format:kShortTimeFormat]]>=0){
            [AppDelegate shareInstance].showAdvertisement = YES;
            [[AppDelegate shareInstance] updateWindowRootVC];
        }else{
            [NSThread sleepForTimeInterval:3.0];
            [[AppDelegate shareInstance] updateWindowRootVC];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_ADVERTISEMENT_DATA];
        if(dict&&[NSDate daysAwayFromToday:[NSDate dateFromString:dict[@"begintime"] format:kShortTimeFormat]]<=0&&[NSDate daysAwayFromToday:[NSDate dateFromString:dict[@"endtime"] format:kShortTimeFormat]]>=0){
            [AppDelegate shareInstance].showAdvertisement = YES;
            [[AppDelegate shareInstance] updateWindowRootVC];
        }else{
            [NSThread sleepForTimeInterval:3.0];
            [[AppDelegate shareInstance] updateWindowRootVC];
        }
    }];
}

@end
