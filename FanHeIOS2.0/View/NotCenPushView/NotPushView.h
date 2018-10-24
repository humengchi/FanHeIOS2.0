//
//  NotPushView.h
//  FanHeIOS2.0
//
//  Created by renhao on 2016/11/11.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NotPushViewDelegate <NSObject>

- (void)removeWindow;
- (void)tapImageAction;

@end

@interface NotPushView : UIView
@property (nonatomic,weak) id <NotPushViewDelegate>notPushViewDelegate;
- (void)createrPushView:(NSString *)imageStr;
@end
