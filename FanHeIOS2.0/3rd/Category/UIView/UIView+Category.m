//
//  UIView+Category.m
//  ChannelPlus
//
//  Created by Mobilizer on 15/5/14.
//  Copyright (c) 2015年 Peter. All rights reserved.
//

#import "UIView+Category.h"

@implementation UIView (Category)

- (void)shakeByRotation:(int)repeatCount {
    CATransform3D transform;
    if (arc4random() % 2 == 1)//这是为了让不同的View对象向左或向右转动
        transform = CATransform3DMakeRotation(-0.08, 0, 0, 1.0);//
    else
        transform = CATransform3DMakeRotation(0.08, 0, 0, 1.0);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:transform];
    animation.autoreverses = YES;
    animation.duration = 0.1;   //间隔时间
    animation.repeatCount = repeatCount;   //重复的次数
    animation.delegate = self;
    [[self layer] addAnimation:animation forKey:@"wiggleAnimation"];
}

- (void)shakeByTranslation:(int)repeatCount {
    CATransform3D transform = CATransform3DMakeTranslation(-20, 0, 0);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:transform];
    animation.autoreverses = YES;
    animation.duration = 0.07;   //间隔时间
    animation.repeatCount = repeatCount;   //重复的次数
    animation.delegate = self;
    [[self layer] addAnimation:animation forKey:@"wiggleAnimation"];
}

- (UIView *)subviewWithTag:(NSInteger)tag {
    for (UIView *subView in self.subviews) {
        if (subView.tag == tag) {
            return subView;
        }
    }
    return nil;
}

- (UIViewController *)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    if([AppDelegate shareInstance].tabBarController){
        return ((UINavigationController*)[AppDelegate shareInstance].tabBarController.selectedViewController).topViewController;
    }else{
        return ((UINavigationController*)[AppDelegate shareInstance].window.rootViewController).topViewController;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
