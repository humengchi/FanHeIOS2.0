//
//  MainWebVC.m
//  ddquickbao
//
//  Created by app on 16/7/13.
//  Copyright © 2016年 Personal. All rights reserved.

//

#import "MainWebVC.h"
#import <WebKit/WebKit.h>
#import "MBProgressHUD.h"

//适配iPhoneX
#define isiPhoneX (ScreenHeight == 812 ? YES : NO)
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define kStatusBarHeight (ScreenHeight == 812 ? 44 : 20)
#define isiPhoneX (ScreenHeight == 812 ? YES : NO)
#define IphoneXExtraH (ScreenHeight == 812 ? 34 : 0)
#define NavBarHeight  (ScreenHeight == 812 ? 88 : 64)
#define UIColorFromRGB(rgbValue) [[UIColor alloc] initWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

static MainWebVC *controller = nil;

@interface MainWebVC () <WKNavigationDelegate,WKScriptMessageHandler,WKUIDelegate>

@property (nonatomic, strong, nonnull) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progress;//进度条
@property (nonatomic, strong) UIView *stautsView;
@property (nonatomic, strong) UIView *footView;
@property (nonatomic, weak)   MBProgressHUD *hud;
@property (nonatomic, assign) BOOL isSuccess;
@end

@implementation MainWebVC

#pragma mark - 初始化和生命周期
- (void)dealloc{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

+ (instancetype)shareController{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [[self alloc] init];
    });
    return controller;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setupUI];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    self.stautsView.frame = CGRectMake(0, 0, ScreenWidth, kStatusBarHeight);
    if (isiPhoneX) {
        self.webView.frame = CGRectMake(0, kStatusBarHeight, ScreenWidth, ScreenHeight - kStatusBarHeight - IphoneXExtraH);
        self.footView.frame = CGRectMake(0, CGRectGetMaxY(self.webView.frame), ScreenWidth, IphoneXExtraH);
    }else{
        self.webView.frame = CGRectMake(0, kStatusBarHeight, ScreenWidth, ScreenHeight - kStatusBarHeight);
    }
}

#pragma mark - Target方法

#pragma mark - HTTP请求

#pragma mark - 懒加载
- (WKWebView *)webView{
    if(!_webView){
        WKWebViewConfiguration *config =[[WKWebViewConfiguration alloc]init];
        config.preferences.javaScriptEnabled = YES;
        /** 默认是不能通过JS自动打开窗口的，必须通过用户交互才能打开 */
        config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        _webView.allowsBackForwardNavigationGestures = YES;//打开左划回退功能
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;//弹框代理
        _webView.backgroundColor = [UIColor whiteColor];
    }
    return _webView;
}

- (UIProgressView *)progress{
    if(!_progress){
        CGFloat x       = 0;
        CGFloat y       = (self.navigationController && !self.navigationController.navigationBar.hidden) ? NavBarHeight : kStatusBarHeight;
        CGFloat width   = ScreenWidth;
        CGFloat height  = 5;
        
        _progress = [[UIProgressView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _progress.trackTintColor = [UIColor clearColor];
        _progress.progressTintColor = [UIColor greenColor];
        [self.view addSubview:_progress];
        
    }
    return _progress;
}

- (UIView *)stautsView{
    if(!_stautsView){
        _stautsView = [[UIView alloc]init];
        _stautsView.backgroundColor = UIColorFromRGB(0x199BE1);
    }
    return _stautsView;
}

- (UIView *)footView{
    if(!_footView){
        _footView = [[UIView alloc]init];
        _footView.backgroundColor = UIColorFromRGB(0xFFFFFF);
        //198928
    }
    return _footView;
}

#pragma mark - 自定义方法
- (void)setupUI{
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.stautsView];
    [self.view addSubview:self.webView];
    if (isiPhoneX) {
        [self.view addSubview:self.footView];
    }
    //监听webView的estimatedProgress属性变化
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];;
    hud.frame = CGRectMake(0, kStatusBarHeight, ScreenWidth, ScreenHeight - kStatusBarHeight);
    hud.backgroundColor = [UIColor whiteColor];
    hud.label.text = @"正在加载...";
    self.hud = hud;
}

- (void)loadWithUrl:(NSString *)url{
    if (!self.isSuccess) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [self.webView loadRequest:request];
    }
}

//进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        double progress = self.webView.estimatedProgress;
        /** 用当前获取的进度值去处理进度条控件 */
        self.progress.progress = progress < 1.0 ? progress : 0.0;
        
    }
}

#pragma mark - 代理和协议

#pragma mark ----WKNavigationDelegate----
//页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    
    NSLog(@"页面开始加载时调用");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}
//当内容开始返回时调用
- (void)webView:(WKWebView*)webView didCommitNavigation:(WKNavigation*)navigation {
    
    NSLog(@"当内容开始返回时调用");
}

//页面加载完成之后调用
- (void)webView:(WKWebView*)webView didFinishNavigation:(WKNavigation*)navigation {
    
    NSLog(@"页面加载完成之后调用");
    self.isSuccess = YES;
    [self.hud hideAnimated:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    
    NSLog(@"加载错误");
    [self.hud hideAnimated:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark ----JS代理----
/**代理方法
 JS通过mymobile发送数据到iOS端时，在代理中接收
 var message = {"method":"take","args":"let go"};
 window.webkit.messageHandlers.mymobile(注:这里是注入的对象名).postMessage(message);
 */
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
}

#pragma mark ----alert代理----
/**  在JS端调用alert函数时，会触发此代理方法（确认框） */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertVC animated:YES completion:nil];
    
    completionHandler();
}


//可以跳转appStore
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    if(webView != self.webView) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    NSString *urlString = navigationAction.request.URL.absoluteString;
   
    if ([webView.URL.absoluteString containsString:@"itunes.apple.com"]) {
        
        if ([[UIApplication sharedApplication] canOpenURL:webView.URL]) {
            
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:webView.URL options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:webView.URL];
            }
            
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
 
    if ([urlString containsString:@"://?"]) {
        
        if ([[UIApplication sharedApplication] canOpenURL:navigationAction.request.URL]) {
            
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
            }
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}


- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    if (!navigationAction.targetFrame.isMainFrame) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        }
    }
    return nil;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end

