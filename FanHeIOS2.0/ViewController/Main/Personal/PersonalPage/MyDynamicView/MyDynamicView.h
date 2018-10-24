//
//  MyDynamicView.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/3/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyDynamicView : UIView
@property (weak, nonatomic) IBOutlet UILabel *statLabel;
- (void)updateDisplay:(BOOL)isHome;
@end
