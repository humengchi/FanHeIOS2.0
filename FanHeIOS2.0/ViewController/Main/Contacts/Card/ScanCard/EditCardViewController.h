//
//  EditCardViewController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/14.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseKeyboardViewController.h"

@interface EditCardViewController : BaseKeyboardViewController

@property (nonatomic, strong) CardScanModel *model;

@property (nonatomic, assign) BOOL isEdit;

@end
