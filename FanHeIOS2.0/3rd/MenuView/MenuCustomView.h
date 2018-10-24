//
//  MenuCustomView.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/3/6.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuCustomView : UIView

@property (nonatomic, strong) void(^menuSelectedIndex)(NSInteger index);

- (id)initWithFrame:(CGRect)frame isTop:(BOOL)isTop isAttent:(BOOL)isAttent;

@end
