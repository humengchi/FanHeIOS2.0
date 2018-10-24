//
//  RechargeIntroController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/10.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "RechargeIntroController.h"

@interface RechargeIntroController ()

@end

@implementation RechargeIntroController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar:@"充值流程说明"];
    
    [self initScrollView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.scrollView.backgroundColor = kTableViewBgColor;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 1889*WIDTH/375.0)];
    imageView.image = kImageWithName(@"image_czsm");
    [self.scrollView addSubview:imageView];
    
    [self.scrollView setContentSize:CGSizeMake(WIDTH, 1889*WIDTH/375.0)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
