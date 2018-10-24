//
//  GlobalDefine.h
//  JinMai
//
//  Created by 胡梦驰 on 16/3/22.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#ifndef GlobalDefine_h
#define GlobalDefine_h

#define BundleID @"com.fortunecoffee.51JinMai"

//友盟配置
#define UmengAppkey @"56dd4e81e0f55ad3920027d3"
#define EMLoginPasswd @"$2y$10$qDhx5uJr8nYc.92Inwq4m.Sc4aArrInrGtM405MsEi/ykxpH8ESp6"

//友盟新浪
#define UmSSOApp   @"3914913052"
#define UmSSOSecret   @"4915a86f4a5171bcaba1a0fba4756393" 
#define UmSSoHttp    @"http://sns.whalecloud.com/sina2/callback"

//友盟微信
#define UmWeixinAppkey @"wx9815a79d4c6e671b"
#define UmWeixinappSecret  @"c757a5e0c1fea85cc33b84bff7c49965"
#define UmWeixinHttp @"http://wx.51jinmai.com"

//环信密码、配置
#define EMLoginPasswd @"$2y$10$qDhx5uJr8nYc.92Inwq4m.Sc4aArrInrGtM405MsEi/ykxpH8ESp6"

//环信
#if DEBUG==1
    #define HuanXinKey     @"51jinmai#jinmai-test"
    #define PushtheCertificate     @"dev"
#else
    #define HuanXinKey     @"51jinmai#jinmai"
    #define PushtheCertificate     @"pro"
#endif

//通知设置
#define VoiceKey @"VoiceKey"
#define DampingKey @"DampingKey"
#define ShowDetailKey @"ShowDetailKey"
#define SendCard   @"SendCard"
#define MyFriendsChange @"MyFriendsChange"

//颜色设置
#define kDefaultColor HEX_COLOR(@"E24943")
#define kBackgroundColorDefault HEX_COLOR(@"EFEFF4")
#define kTabbarBgColor HEX_COLOR(@"FAFAFA")
#define kCellLineColor HEX_COLOR(@"d9d9d9")
#define kTableViewBgColor HEX_COLOR(@"EFEFF4")
#define KTextColor HEX_COLOR(@"818C9E")

//默认用户头像
#define KHeadImageDefault kImageWithName(@"head_image_default")
#define KWidthImageDefault kImageWithName(@"jztp")
#define KHeightImageDefault kImageWithName(@"jztp_b")
#define KSquareImageDefault kImageWithName(@"jztp_square")
#define KBlankImageDefault kImageWithName(@"jztp_k")
#define KEqualWHImageDefault kImageWithName(@"equalWH")
#define KHeadImageDefaultName(name) [UIImage createHeaderImageWithString:name]

//广告二维码
#if DEBUG==1
#define FristAdURL @"http://wx-test.51jinmai.com/activity/detail/"
#else
#define FristAdURL @"http://wx.51jinmai.com/activity/detail/"
#endif

//群组二维码
#if DEBUG==1
#define GroupURL @"http://wx-test.51jinmai.com/activity/GroupURL/"
#else
#define GroupURL @"http://wx.51jinmai.com/activity/GroupURL/"
#endif

//人脉咖啡二维码url
#if DEBUG==1
#define CoffeeQRCodeURL @"http://wx-test.51jinmai.com/coffee/get/"
#else
#define CoffeeQRCodeURL @"http://wx.51jinmai.com/coffee/get/"
#endif

//通知@人url
#if DEBUG==1
#define NotificationURL @"http://wx-test.51jinmai.com/member/hishome/"
#else
#define NotificationURL @"http://wx.51jinmai.com/member/hishome/"
#endif

//邀请下载
#define DownloadUrl @"http://wx.51jinmai.com/coffee/relatego"

//分享名片Url
#if DEBUG==1
#define ShareCardUrl @"http://wx-test.51jinmai.com/app/card"
#else
#define ShareCardUrl @"http://wx.51jinmai.com/app/card"
#endif

//分享邀请好友
#if DEBUG==1
#define InvitFriendRegisterUrl @"http://wx-test.51jinmai.com/coffee/reg/"
#else
#define InvitFriendRegisterUrl @"http://wx.51jinmai.com/coffee/reg/"
#endif

//分享主页
#if DEBUG==1
#define ShareHomePageURL @"http://wx-test.51jinmai.com/member/hishome/"
#else
#define ShareHomePageURL @"http://wx.51jinmai.com/member/hishome/"
#endif

//活动分享
#if DEBUG==1
#define ShareActivityPageURL @"http://wx-test.51jinmai.com/activity/detail/"
#else
#define ShareActivityPageURL @"http://wx.51jinmai.com/activity/detail/"
#endif

//活动详情
#if DEBUG==1
#define PostDetailURL @"http://wx.51jinmai.com/app/post/detail"
#else
#define PostDetailURL @"http://wx.51jinmai.com/app/post/detail"
#endif

//人脉关系图
#if DEBUG==1
#define NET_RELATION_URL @"http://wx-test.51jinmai.com/coffee/netrelation"
#else
#define NET_RELATION_URL @"http://wx.51jinmai.com/coffee/netrelation"
#endif

//专栏url
#if DEBUG==1
#define  WebUrl  @"http://wx-test.51jinmai.com/app/post/djtalk"
#else
#define  WebUrl  @"http://wx.51jinmai.com/app/post/djtalk"
#endif

//分享集赞
#if DEBUG==1
#define  WX_COLLECT_ZAN  @"http://wx-test.51jinmai.com/coffee/wx_avt1/"
#else
#define  WX_COLLECT_ZAN  @"http://wx.51jinmai.com/coffee/wx_avt1/"
#endif

//话题分享url
#if DEBUG==1
#define TOPIC_SHARE_URL @"http://wx-test.51jinmai.com/subject/detail/"
#else
#define TOPIC_SHARE_URL @"http://wx.51jinmai.com/subject/detail/"
#endif

//观点分享url
#if DEBUG==1
#define VIEWPOINT_SHARE_URL @"http://wx-test.51jinmai.com/subject/viewpoint/"
#else
#define VIEWPOINT_SHARE_URL @"http://wx.51jinmai.com/subject/viewpoint/"
#endif

//资讯详情分享url
#if DEBUG==1
#define INFORMATION_SHARE_URL @"http://wx-test.51jinmai.com/post/detail/"
#else
#define INFORMATION_SHARE_URL @"http://wx.51jinmai.com/post/detail/"
#endif

//动态详情分享
#if DEBUG==1
#define DYNAMIC_SHARE_URL @"http://wx-test.51jinmai.com/app/dynamic/"
#else
#define DYNAMIC_SHARE_URL @"http://wx.51jinmai.com/app/dynamic/"
#endif

//海报生成image
#if DEBUG==1
#define POSTER_TO_IMAGE_URL @"http://wx-test.51jinmai.com/app/cardtoimg"
#else
#define POSTER_TO_IMAGE_URL @"http://wx.51jinmai.com/app/cardtoimg"
#endif

//这是h5查询企业信息的网址
#if DEBUG==1
#define SEARCH_COMPANY_URL @"http://wx-test.51jinmai.com/company/companysrh"
#define isProductionBool 0
#else
#define SEARCH_COMPANY_URL @"http://wx.51jinmai.com/company/companysrh"
#define isProductionBool 1
#endif

//这是h5查询企业信息的网址,历史记录的
#if DEBUG==1
#define SEARCH_COMPANY_HISTORY_URL @"http://wx-test.51jinmai.com/company/detail"
#else
#define SEARCH_COMPANY_HISTORY_URL @"http://wx.51jinmai.com/company/detail"
#endif

//屏幕的宽高
#define WIDTH  [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

//ios系统版本
#define IOS_X  [[UIDevice currentDevice].systemVersion doubleValue]

//是否第一次启动，导航栏
#define NOT_FIRST_LAUNCH @"NotFirstLaunch_2.3.0"

//登录广告，本地缓存
#define LOGIN_ADVERTISEMENT_DATA @"login_advertisement_data"

//第一次进入首页，进行遮层引导
#define FirstLaunchGuideViewMark @"FirstLaunchGuideViewMark_2.6.0"

//第一次进入我的主页，进行遮层引导
#define FirstLaunchGuideViewMarkMySelf @"FirstLaunchGuideViewMarkMySelf_2.6.0"

//第一次进入人脉首页，进行遮层引导
#define FirstLaunchGuideViewMarkContact @"FirstLaunchGuideViewMarkContact_2.6.0"

//第一次进入手机通讯录
#define NotFirstVisitingPhoneBook @"NotFirstVisitingPhoneBook"

//第一次使用麦克风
#define FirstAVAudioSession @"FirstAVAudioSession"

//头像是否上传提示，记录上一次显示的时间
#define ShowCompleteUserInfoEditViewDate [NSString stringWithFormat:@"ShowCompleteUserInfoEditViewDate%@", [DataModelInstance shareInstance].userModel.userId]

//草稿保存
#define SAVE_TEMP_POSTS_MODEL(categoryType) [NSString stringWithFormat:@"categoryType_%@", categoryType]

//动态发布保存
#define SAVE_DYNAMIC_MODEL @"saveDynamicModel"

//个人登录信息保存到本地
#define SAVE_LOGIN_USER_MODEL @"saveLoginUserModel"

//管理员登录信息保存到本地
#define SAVE_ADMIN_LOGIN_USER_MODEL @"saveAdminLoginUserModel"

//消息通知、
#define hNSNotificationCenter  [NSNotificationCenter defaultCenter]
#define hNSUserDefaultsShare   [NSUserDefaults standardUserDefaults]


//删除右上角的未读消息通知
#define DeleteUserNewMsg @"DeleteUserNewMsg"

//评论
#define  ratePostName  @"ratePostName"
#define  InformationRefar  @"InformationRefar"
//活动頁菜单刷新
#define  ACTIVITYDOWNMENU  @"ACTIVITYDOWNMENU"
//关注
#define  ATTIONHISACTIVEORTALK  @"ATTIONHISACTIVEORTALK"
 //删除或者回复
#define  DELECTACTIVITYACTION    @"DELECTACTIVITYACTION"

//路径
#define D_PATH_DB_LOCAL [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/User/%@",[DataModelInstance shareInstance].userModel.userId?[DataModelInstance shareInstance].userModel.userId:@"tmp"]]

//内购
#define AppStoreInfoLocalFilePath [NSString stringWithFormat:@"%@/%@/", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],@"EACEF35FE363A75A"]
#define IAP_RECEIPT @"iap_receipt"
#define IAP_DATE @"iap_date"
#define IAP_USER_ID @"iap_user_id"

#define D_PATH_DB_ALL_LOCAL [NSString stringWithFormat:@"%@/JinMai.db",D_PATH_DB_LOCAL]

//群组头像保存到本地
#define SAVE_GROUP_HEADER_IMAGE(groupId) [NSString stringWithFormat:@"%@/%@.png",D_PATH_DB_LOCAL, groupId]

#define CoverViewColor [UIColor colorWithRed:65/255.0 green:70/255.0 blue:78/255.0 alpha:0.5]
//收起下拉
#define packUpMenu  @"packUpMenu"

#endif /* GlobalDefine_h */
