//
//  NewUserNoticeView.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/10/28.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, NewUserNoticeViewType) {
    NewUserNoticeViewType_None,
    NewUserNoticeViewType_NewApplyFriend,
    NewUserNoticeViewType_NewVisitor,
};

typedef void(^NewUserNoticeViewRemoveView)();

@interface NewUserNoticeView : UIView

@property (nonatomic, strong) NewUserNoticeViewRemoveView newUserNoticeViewRemoveView;

- (id)initWithFrame:(CGRect)frame model:(HomeDataModel*)model;

@end
