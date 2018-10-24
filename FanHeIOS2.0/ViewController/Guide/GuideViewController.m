//
//  GuideViewController.m
//  Promotion
//
//  Created by HuMengChi on 15/10/10.
//  Copyright (c) 2015年 hmc. All rights reserved.
//

#import "GuideViewController.h"

@interface GuideViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation GuideViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = WHITE_COLOR;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.delegate = self;
    [scrollView setContentSize:CGSizeMake(WIDTH*3, HEIGHT)];
    scrollView.pagingEnabled = YES;
    NSString *size = @"";
    if(WIDTH == 320 && HEIGHT == 480){
        size = @"4";
    }else if(WIDTH == 320 && HEIGHT == 568){
        size = @"5";
    }else  if(WIDTH == 375 && HEIGHT == 667){
        size = @"6";
    }else{
        size = @"6p";
    }
    for (int i = 0; i < 3; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH*i, 0, WIDTH, HEIGHT)];
        imageView.image = kImageWithName(([NSString stringWithFormat:@"%@-%d",size, i+1]));
        [scrollView addSubview:imageView];
        if(i == 2){
            imageView.userInteractionEnabled = YES;
            [CommonMethod viewAddGuestureRecognizer:imageView tapsNumber:1 withTarget:self withSEL:@selector(gotoLogin_guide)];
        }
    }
    [self.view addSubview:scrollView];
    
    self.pageControl = [[UIPageControl alloc] init];
    CGSize sizes = [self.pageControl sizeForNumberOfPages:3];
    self.pageControl.frame = CGRectMake(0, HEIGHT-40, sizes.width, sizes.height);
    self.pageControl.center = CGPointMake(WIDTH/2+15, HEIGHT-30);
    [self.pageControl setCurrentPageIndicatorTintColor:kDefaultColor];
    [self.pageControl setPageIndicatorTintColor:[UIColor colorWithPatternImage:[kImageWithName(@"scrollVIew_Unselected") imageWithColor:kDefaultColor]]];
    self.pageControl.numberOfPages = 3;
    self.pageControl.currentPage = 0;
//    [self.view addSubview:self.pageControl];
}

- (void)gotoLogin_guide{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setBool:YES forKey:NOT_FIRST_LAUNCH];
    [userDefault synchronize];
    if([DataModelInstance shareInstance].adminUserModel){
        [[AppDelegate shareInstance] gotoAdminMainVC];
    }else if([DataModelInstance shareInstance].userModel){
        [[AppDelegate shareInstance] updateWindowRootVC];
    }else{
        [[AppDelegate shareInstance] gotoRegisterGuide];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    float index = scrollView.contentOffset.x;
    if(index<0 || index>WIDTH*2){
        scrollView.scrollEnabled = NO;
        sleep(0.05);
        scrollView.scrollEnabled = YES;
    }
    if(index>WIDTH*2){
        [self gotoLogin_guide];
    }
    self.pageControl.currentPage = (int)index/WIDTH;
}

@end
