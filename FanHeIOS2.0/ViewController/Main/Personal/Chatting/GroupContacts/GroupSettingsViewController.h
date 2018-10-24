//
//  GroupSettingsViewController.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/8/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

@interface GroupSettingsViewController : BaseViewController
@property (nonatomic ,strong) NSString *groupID;
@property (strong, nonatomic) EMConversation *conversation;
@end
