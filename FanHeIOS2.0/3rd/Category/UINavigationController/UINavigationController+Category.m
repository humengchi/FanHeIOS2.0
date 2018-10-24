//
//  UINavigationController+Category.m
//  ChannelPlus
//
//  Created by Peter on 15/1/25.
//  Copyright (c) 2015年 Peter. All rights reserved.
//

#import "UINavigationController+Category.h"

@implementation UINavigationController (Category)


- (BOOL)shouldAutorotate {
    return [self.viewControllers.lastObject shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations {
    return [self.viewControllers.lastObject supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.viewControllers.lastObject preferredInterfaceOrientationForPresentation];
}


@end
