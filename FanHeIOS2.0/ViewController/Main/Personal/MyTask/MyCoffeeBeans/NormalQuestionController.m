//
//  NormalQuestionController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/10.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "NormalQuestionController.h"
#import "RechargeIntroController.h"

@interface NormalQuestionController ()

@end

@implementation NormalQuestionController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar:@"常见问题"];
    
    [self initScrollView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.scrollView.backgroundColor = kTableViewBgColor;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 787*WIDTH/375.0)];
    imageView.image = kImageWithName(@"image_cjwt");
    [self.scrollView addSubview:imageView];
    
    [self.scrollView setContentSize:CGSizeMake(WIDTH, 787*WIDTH/375.0)];
    
    UIButton *rechargeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rechargeBtn.frame = CGRectMake(0, 555*WIDTH/375.0, WIDTH, 14);
    [rechargeBtn addTarget:self action:@selector(rechargeInfoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:rechargeBtn];
    
    UIButton *phoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    phoneBtn.frame = CGRectMake(0, 717*WIDTH/375.0, WIDTH, 14);
    [phoneBtn addTarget:self action:@selector(phoneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:phoneBtn];
}

#pragma mark -method
- (void)rechargeInfoButtonClicked:(id)sender{
    RechargeIntroController *vc = [[RechargeIntroController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)phoneButtonClicked:(id)sender{
    NSString *str = [NSString stringWithFormat:@"tel:021-65250669"];
    UIWebView *callWebView = [[UIWebView alloc]init];
    [callWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
    [[UIApplication sharedApplication].keyWindow addSubview:callWebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
