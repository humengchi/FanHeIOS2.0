//
//  CheckCodeViewController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/1.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//


#import "BaseKeyboardViewController.h"

@interface CheckCodeViewController : BaseKeyboardViewController

@property (nonatomic, copy) NSString    *phoneStr;

@property (nonatomic, assign) Code_Type  codeType;

@property (nonatomic, assign) NSInteger typeIndex;

@end
