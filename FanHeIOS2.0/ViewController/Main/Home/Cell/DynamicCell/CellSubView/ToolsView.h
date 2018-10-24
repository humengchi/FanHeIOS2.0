//
//  ToolsView.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/3/1.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToolsView : UIView

- (void)updateDisplay:(DynamicModel*)model;

@property (nonatomic, strong) void(^reviewDynamic)();

@property (nonatomic, strong) DynamicModel *model;

@end
