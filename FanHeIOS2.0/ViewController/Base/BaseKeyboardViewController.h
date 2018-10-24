//
//  BaseKeyboardViewController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/7/29.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseKeyboardViewController : BaseViewController


@property (weak, nonatomic) IBOutlet UIButton *backNavBtn;

@property (nonatomic, assign) BOOL  hideBackNavBtn;

- (void)removeViewTapGesture;

@end
