//
//  EditPersonalInfoViewController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/25.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseKeyboardViewController.h"

typedef NS_ENUM(NSUInteger, SaveType) {
    SaveType_Normal,
    SaveType_AddFriends,//多个
    SaveType_Identify,//3个
};

typedef void(^SavePersonalInfoSuccess)();

@interface EditPersonalInfoViewController : BaseKeyboardViewController

@property (nonatomic, strong) SavePersonalInfoSuccess savePersonalInfoSuccess;
@property (nonatomic,assign) SaveType saveType;
@end
