//
//  UITabBarController+Animation.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2018/9/20.
//  Copyright © 2018年 胡梦驰. All rights reserved.
//

#import "UITabBarController+Animation.h"

@implementation UITabBarController (Animation)
// 点击tabbarItem自动调用
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSInteger index = [self.tabBar.items indexOfObject:item];
    
    [self animationWithIndex:index];
    
    if([item.title isEqualToString:@"发现"])
    {
        // 也可以判断标题,然后做自己想做的事
    }
    
}
- (void)animationWithIndex:(NSInteger) index {
    NSMutableArray * tabbarbuttonArray = [NSMutableArray array];
    for (UIView *tabBarButton in self.tabBar.subviews) {
        if ([tabBarButton isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            [tabbarbuttonArray addObject:tabBarButton];
        }
    }
    /**
     CABasicAnimation类的使用方式就是基本的关键帧动画。
     
     所谓关键帧动画，就是将Layer的属性作为KeyPath来注册，指定动画的起始帧和结束帧，然后自动计算和实现中间的过渡动画的一种动画方式。
     */
    CABasicAnimation*pulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    pulse.timingFunction= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulse.duration = 0.2;
    pulse.repeatCount= 1;
    pulse.autoreverses= YES;
    pulse.fromValue= [NSNumber numberWithFloat:0.8];
    pulse.toValue= [NSNumber numberWithFloat:1.3];
    [[tabbarbuttonArray[index] layer]
     addAnimation:pulse forKey:nil];
}

@end
