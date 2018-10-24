//
//  CreateActivityViewController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/30.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseKeyboardViewController.h"

@interface CreateActivityViewController : BaseKeyboardViewController

@property (nonatomic, strong) ActivityCreateModel *model;

@property (nonatomic, assign) BOOL isEdit;

@end
