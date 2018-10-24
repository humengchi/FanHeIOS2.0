//
//  PosterWebViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/2/21.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "PosterWebViewController.h"
#import "PosterShareViewController.h"

@interface PosterWebViewController ()<UIWebViewDelegate>{
    BOOL _isHandBack;
}

@property (nonatomic, weak) IBOutlet UIWebView *webview;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, weak) IBOutlet UIButton *saveBtn;

@end

@implementation PosterWebViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self setNavigationBar_kdefaultColor];
    _isHandBack = NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return NO;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(!_isHandBack){
        [self setNavigationBar_white];
    }else{
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webview.delegate = self;
    self.webview.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    self.webview.backgroundColor = kTableViewBgColor;
    UserModel *model = [DataModelInstance shareInstance].userModel;
    NSString *url = [NSString stringWithFormat:@"%@?name=%@&company=%@&position=%@&phone=%@&intro=%@&image=%@",POSTER_TO_IMAGE_URL,[CommonMethod paramStringIsNull:model.realname],[CommonMethod paramStringIsNull:model.company],[CommonMethod paramStringIsNull:model.position],[CommonMethod paramStringIsNull:model.phone],@"",[CommonMethod paramStringIsNull:model.image]];
    url = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)url, (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]", NULL, kCFStringEncodingUTF8));
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.webview loadRequest:request];
    [self.view addSubview:self.webview];
}

#pragma mark ----------//UIWebview代理
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *requestString = [[request URL] absoluteString];
    if ([requestString isEqualToString:@"about:blank"]) {
        self.saveBtn.hidden = NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    if(self.hud == nil){
        self.hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    if (webView.isLoading) {
        return;
    }
    [self.hud hideAnimated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self.hud hideAnimated:YES];
}

- (IBAction)saveButtonClicked:(id)sender{
    [self newThreadForAvoidButtonRepeatClick:sender];
    NSString *str = [self.webview stringByEvaluatingJavaScriptFromString:@"document.getElementById('cardimg').src"];
    str = [str stringByReplacingOccurrencesOfString:@"data:image/png;base64," withString:@""];
    if(str.length==0){
        [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"生成海报失败！" cancelButtonTitle:nil otherButtonTitle:@"确定" cancle:nil confirm:^{
        }];
        return;
    }
    NSData *imgData = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *image = [UIImage imageWithData:imgData];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if(error){
        [self.view showToastMessage:@"图片保存失败，请重试！"];
        return;
    }
    [[AppDelegate shareInstance] setZhugeTrack:@"保存海报" properties:@{}];
    _isHandBack = YES;
    PosterShareViewController *vc = [[PosterShareViewController alloc] init];
    vc.posterImage = image;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)backButtonClicked:(id)sender{
    _isHandBack = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
