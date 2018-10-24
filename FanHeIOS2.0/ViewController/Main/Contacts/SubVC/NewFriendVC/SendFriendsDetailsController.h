//
//  SendFriendsDetailsController.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/30.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^AddFriendSuccess) (BOOL success);
@interface SendFriendsDetailsController : BaseViewController
@property (nonatomic, strong) NSNumber *otherID;
@property (nonatomic, strong) AddFriendSuccess addFriendsSuccess;

@end
