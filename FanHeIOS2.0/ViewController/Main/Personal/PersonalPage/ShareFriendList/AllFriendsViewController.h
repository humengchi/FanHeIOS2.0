//
//  AllFriendsViewController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/18.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

@interface AllFriendsViewController : BaseViewController
//发送名片参数
@property (nonatomic ,strong)  NSString *position;
@property (nonatomic ,strong)  NSString *imagUrl;
@property (nonatomic ,strong)  NSString *nameCatergoryStr;
@property (nonatomic ,strong)  NSString *gooAtStr;
@property (nonatomic ,strong)  NSNumber *userID;
@property (nonatomic, assign) BOOL isSendCard;
@property (nonatomic, assign) BOOL isInviteCommend;//邀请评论

//动态
@property (strong ,nonatomic) DynamicModel *dymodel;
//转发
@property (strong ,nonatomic) EaseMessageModel *messageModel;
@property (strong ,nonatomic) UserModel *useModel;
//分享活动给好友
@property (strong, nonatomic) MyActivityModel *actModel;
@property (nonatomic, assign) BOOL isViewPoint;
@property (nonatomic, assign) BOOL isDynamicAt;//发表动态中的@
@property (nonatomic, strong) void(^dynamicAtUser)(ChartModel *model);


@property (strong ,nonatomic) CardScanModel *cardModel;

@end
