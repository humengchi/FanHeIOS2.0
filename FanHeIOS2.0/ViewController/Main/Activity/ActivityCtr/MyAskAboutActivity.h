//
//  MyAskAboutActivity.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol MyAskAboutActivityDelegate <NSObject>

- (void)referAskView;

@end

@interface MyAskAboutActivity : BaseViewController
@property (nonatomic ,strong)  NSNumber *activityid;
@property (nonatomic ,weak) id<MyAskAboutActivityDelegate>myAskAboutActivityDelegate;
@end
