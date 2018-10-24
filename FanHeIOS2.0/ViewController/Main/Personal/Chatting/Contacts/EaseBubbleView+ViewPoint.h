//
//  EaseBubbleView+ViewPoint.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/3/28.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "EaseBubbleView.h"

@interface EaseBubbleView (ViewPoint)
- (void)setupViewPointBubbleView:(id<IMessageModel>)model;
- (void)updateViewPointMargin:(UIEdgeInsets)margin model:(id<IMessageModel>)model;
@end
