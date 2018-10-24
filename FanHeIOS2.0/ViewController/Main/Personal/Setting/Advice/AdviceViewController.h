//
//  AdviceViewController.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/26.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdviceViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UITextView *AdviceTextView;
@property (weak, nonatomic) IBOutlet UILabel *showLabel;
@property (weak, nonatomic) IBOutlet UIButton *AddImageBtn;
@property (strong, nonatomic) UIButton *releaseButton;
@end
