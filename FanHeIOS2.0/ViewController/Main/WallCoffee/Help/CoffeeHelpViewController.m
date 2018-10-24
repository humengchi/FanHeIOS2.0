//
//  CoffeeHelpViewController.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/1.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "CoffeeHelpViewController.h"

@interface CoffeeHelpViewController ()
@property (nonatomic,strong)NSArray *dataArray;

@end

@implementation CoffeeHelpViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"人脉咖啡";
    [self initScrollView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.scrollView.backgroundColor = HEX_COLOR(@"f3e9dd");
    
    CGFloat height = 1057*WIDTH/375.0;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, height)];
    imageView.image = kImageWithName(@"bg_coffee_gz");
    [self.scrollView addSubview:imageView];
    [self.scrollView setContentSize:CGSizeMake(WIDTH, height)];
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.scrollView.contentOffset.y < 0) {
        self.scrollView.scrollEnabled = NO;
        [self.scrollView setContentOffset:CGPointMake(0, 0)];
    }else{
        self.scrollView.scrollEnabled = YES;
    }
}

@end
