//
//  ChangeFillPhoneController.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/31.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseKeyboardViewController.h"
@interface ChangeFillPhoneController : BaseKeyboardViewController
@property (weak, nonatomic) IBOutlet UIButton *getCode;
@property (weak, nonatomic) IBOutlet UIButton *goBackBtn;
@property (nonatomic, assign) NSInteger typeIndex;
@end
