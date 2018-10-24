//
//  AppDelegate.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/6/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^GetFriendListResult)(BOOL result);

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UITabBarController *tabBarController;
@property (nonatomic, assign) BOOL showAdvertisement;
+(AppDelegate*)shareInstance;

- (void)updateWindowRootVC;
- (void)gotoGuide;
- (void)gotoRegisterGuide;
- (void)gotoLogin;
- (void)gotoRegister;
- (void)gotoAdminMainVC;
- (void)gotoRecommendContacts;
- (void)gotoScanCard;

- (void)showUnreadCountViewItemNO:(NSInteger)index unReadCountSum:(NSInteger)unReadCountSum;
- (void)updateFriendsListArrayData:(GetFriendListResult)result;

- (void)setZhugeTrack:(NSString *)track properties:(NSDictionary *)dict;

- (void)updateMyUserModelData;

- (void)getQiNiuToken;


//点击侧边栏菜单跳转
- (void)gotoOtherViewControllerFromPersonal:(UIViewController*)vc;

- (void)updateMenuNewMsgNum;

@end

