//
//  FirstLaunchGuideView.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/10/27.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

//验证码发送类型
typedef NS_ENUM(NSInteger, FLGV_Type) {
    FLGV_Type_MyPage,
    FLGV_Type_Contact,
    FLGV_Type_HomeVC,
};

@protocol FirstLaunchGuideViewDelegate <NSObject>

- (void)mainFeistMoveMark:(NSInteger)index;

@end

@interface FirstLaunchGuideView : UIView

@property (nonatomic, assign) FLGV_Type viewType;

@property (nonatomic, weak)  id<FirstLaunchGuideViewDelegate> firstLaunchGuideViewDelegate;

- (void)newUserGuide;
@end
