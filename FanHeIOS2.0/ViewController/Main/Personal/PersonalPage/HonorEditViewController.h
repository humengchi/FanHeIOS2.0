//
//  HonorEditViewController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/19.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseKeyboardViewController.h"

//
typedef NS_ENUM(NSInteger, HONOR_TYPE) {
    HONOR_TYPE_ADD,
    HONOR_TYPE_EDIT,
    HONOR_TYPE_DELETE,
};

@interface HonorEditViewController : BaseKeyboardViewController

@property (nonatomic, strong) HonorModel *model;

@property (nonatomic, strong) void(^honorEditSuccess)(HONOR_TYPE type, HonorModel *model);

@end
