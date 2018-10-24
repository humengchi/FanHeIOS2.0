

//
//  VideoUrlController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/5/10.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "VideoUrlController.h"

@interface VideoUrlController ()<UIWebViewDelegate>
@property (nonatomic,strong) MBProgressHUD *hud;

@end

@implementation VideoUrlController
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
    
    [self createCustomNavigationBar:@"活动直播"];

    UIWebView *webview = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT  - 64)];
    [self.view addSubview:webview];
    webview.delegate = self;
    webview.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    webview.backgroundColor = kTableViewBgColor;

    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.videoUrl]]];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
