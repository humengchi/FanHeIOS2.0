//
//  notChoseView.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/5/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol notChoseViewDelegate <NSObject>

- (void)clearAllChoseCondition;

@end


@interface notChoseView : UIView
//add by xiyang
@property (nonatomic,weak)id<notChoseViewDelegate>notChoseViewDelegate;
@property (nonatomic, copy) void(^finishedClearBlock)();//回收回调
@end
