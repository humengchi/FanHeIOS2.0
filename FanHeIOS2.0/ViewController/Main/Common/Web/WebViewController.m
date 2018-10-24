//
//  WebViewController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/11/11.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()<UIWebViewDelegate>
@property (nonatomic,strong) MBProgressHUD *hud;
@end

@implementation WebViewController
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
    if([CommonMethod paramStringIsNull:self.customTitle]){
        [self createCustomNavigationBar:self.customTitle];
    }else{
        [self createCustomNavigationBar:@"活动通知"];
    }
    UIWebView *webview = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT  - 64)];
    [self.view addSubview:webview];
    webview.delegate = self;
    webview.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    webview.backgroundColor = kTableViewBgColor;
    
    self.webUrl = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self.webUrl, (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]", NULL, kCFStringEncodingUTF8));
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.webUrl]]];
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
}

@end
