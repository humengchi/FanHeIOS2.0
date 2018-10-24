//
//  EaseBubbleView+Dynamic.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/3/24.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "EaseBubbleView.h"

@interface EaseBubbleView (Dynamic)
- (void)setupDynamicBubbleView:(id<IMessageModel>)model;
- (void)updateDayMargin:(UIEdgeInsets)margin model:(id<IMessageModel>)model;
@end
