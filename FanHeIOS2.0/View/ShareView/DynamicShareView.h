//
//  DynamicShareView.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/3/3.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^DynamicShareViewIndex)(NSInteger index);

@interface DynamicShareView : UIView

@property (nonatomic,copy) void(^dynamicShareViewIndex)(NSInteger index);

- (void)showOrHideView:(BOOL)show;

@end
