//
//  EaseBubbleView+Activity.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/3/28.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "EaseBubbleView.h"

@interface EaseBubbleView (Activity)
- (void)setupActivityBubbleView:(id<IMessageModel>)model;
- (void)updateActivityMargin:(UIEdgeInsets)margin model:(id<IMessageModel>)model;
@end
