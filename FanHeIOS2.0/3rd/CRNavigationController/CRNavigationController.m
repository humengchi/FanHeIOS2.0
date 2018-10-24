//
//  CRNavigationController.m
//  CRNavigationControllerExample
//
//  Created by Corey Roberts on 9/24/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "CRNavigationController.h"
#import "CRNavigationBar.h"

@interface CRNavigationController ()

@end

@implementation CRNavigationController

- (id)init {
    self = [super initWithNavigationBarClass:[CRNavigationBar class] toolbarClass:nil];
    if(self) {
         _maxAllowedInitialDistance = [UIScreen mainScreen].bounds.size.width;
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithNavigationBarClass:[CRNavigationBar class] toolbarClass:nil];
    if(self) {
        self.viewControllers = @[rootViewController];
        self.navigationBar.barTintColor = kDefaultColor;
    }
    
    return self;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    self.topViewController.hidesBottomBarWhenPushed = YES;
    viewController.hidesBottomBarWhenPushed = YES;
    [super pushViewController:viewController animated:animated];
}

@end
