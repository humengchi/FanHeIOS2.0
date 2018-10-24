//
//  DetaileViewController.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/10/25.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "AdvertDetailViewController.h"
@interface AdvertDetailViewController ()<UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic,strong) MBProgressHUD *hud;
@end

@implementation AdvertDetailViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar:@"详情"];
    self.webview = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT- 64)];
    [self.view addSubview:self.webview];
    self.webview.delegate = self;
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
}

#pragma mark ----------//UIWebview代理
- (void)webViewDidStartLoad:(UIWebView *)webView{
    if(self.hud == nil){
        self.hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.hud hideAnimated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self.hud hideAnimated:YES];
//    [MBProgressHUD showError:@"加载失败" toView:self.view];
}

@end
