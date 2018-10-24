//
//  DetaileViewController.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/10/25.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "DetaileViewController.h"

@interface DetaileViewController ()<UIWebViewDelegate,MWPhotoBrowserDelegate>
@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic,strong) NSMutableArray *mUrlArray;
@property (nonatomic,strong) MWPhotoBrowser *photo;
@property (nonatomic,strong) NSString *str;
@property (nonatomic,strong) MBProgressHUD *hud;
@property (nonatomic,strong) UIView *shareView;
@property (nonatomic,strong) UIView *bottenView;
@property (nonatomic,strong) UIButton *shareBtn;
@property (nonatomic,strong) UIView *coverView;
@property (nonatomic,strong) NSString *titleStr;
@property (nonatomic,strong) NSString *countStr;
@property (nonatomic,strong) UIImage *imageShar;
@property (nonatomic,strong) UIView *footView;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UITapGestureRecognizer *tap;
@property (nonatomic,strong) NSString *useID;
@end

@implementation DetaileViewController

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
  
    if(self.otherTitle.length != 0){
        [self createCustomNavigationBar:self.otherTitle];
    }else if(self.isAddress == YES){
        [self createCustomNavigationBar:@"泛合金融咖啡"];
    }else{
        [self createCustomNavigationBar:nil];
        self.nameLabel = [UILabel createLabel:CGRectMake(70, 32, WIDTH - 140, 24) font:[UIFont systemFontOfSize:17] bkColor:WHITE_COLOR textColor:[UIColor colorWithHexString:@"383838"]];
        self.tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pushTaPage)];
        self.nameLabel.userInteractionEnabled = YES;
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.nameLabel];
    }
    if (self.isAddress == YES) {
        self.webview = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT- 64)];
    }else{
        self.webview = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT- 64 - 55)];
    }
   
    self.webview.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    [self.view addSubview:self.webview];
    self.webview.delegate = self;
    
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    
    [self createrShareDetailView];
    if (self.isAddress == NO) {
        self.footView = [NSHelper createrViewFrame:CGRectMake(0, HEIGHT - 55, WIDTH, 55) backColor:@"f7f7f7"];
        self.footView.userInteractionEnabled = YES;
        
        UILabel *lineLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 0.5)];
        lineLabel1.backgroundColor = kCellLineColor;
        [self.footView addSubview:lineLabel1];
        
        self.shareBtn = [NSHelper createButton:CGRectMake(37.5, 7.5, WIDTH - 75, 40) title:@"分享给好友" unSelectImage:nil selectImage:nil target:self selector:@selector(createrVIew)];
        [self.shareBtn.layer setMasksToBounds:YES];
        [self.shareBtn.layer setCornerRadius:5.0]; //设置矩形四个圆角半径
        self.shareBtn.backgroundColor = [UIColor colorWithHexString:@"E24943"];
        [self.footView addSubview:self.shareBtn];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, WIDTH, 0.5)];
        lineLabel.backgroundColor = kCellLineColor;
        [self.view addSubview:lineLabel];

    }
}

- (void)pushTaPage{
    NewMyHomePageController *myhome = [[NewMyHomePageController alloc]init];
    myhome.userId = [NSNumber numberWithInteger:self.useID.integerValue];
    [self.navigationController pushViewController:myhome animated:YES];
}

- (void)createrVIew{
    [UIView animateWithDuration:0.3 animations:^{
        [self.view addSubview:self.coverView];
        [self.footView removeFromSuperview];
        self.bottenView.frame = CGRectMake(0, HEIGHT - WIDTH * 0.46, WIDTH, WIDTH * 0.46);
    } completion:^(BOOL finished) {
    }];
}

- (void)cancleShawerView{
    [UIView animateWithDuration:0.3 animations:^{
        self.bottenView.frame = CGRectMake(0, HEIGHT, WIDTH, WIDTH * 0.46);
    } completion:^(BOOL finished) {
        [self.view addSubview:self.footView];
        [self.coverView removeFromSuperview];
        
    }];
}
#pragma mark ----- 分享页面
-(void)createrShareDetailView{
    self.coverView = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, HEIGHT ) backColor:@"41464E"];
    self.coverView.backgroundColor = [UIColor colorWithRed:65.0/255.0 green:70.0/255.0 blue:78.0/255 alpha:0.7];
    self.coverView.userInteractionEnabled = YES;
    UITapGestureRecognizer *cancleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancleShawerView)];
    [self.coverView addGestureRecognizer:cancleTap];
    
    self.bottenView = [NSHelper createrViewFrame:CGRectMake(0, HEIGHT , WIDTH, WIDTH * 0.46) backColor:@"FFFFFF"];
    
    self.bottenView.userInteractionEnabled = YES;
    [self.coverView addSubview:self.bottenView];
    
    UIButton *botonBtn = [NSHelper createButton:CGRectMake(0, WIDTH * 0.46 - 50,WIDTH, 50) title:@"取消" unSelectImage:nil selectImage:nil target:self selector:@selector(cancleShawerView)];
    botonBtn.tag = 4;
    botonBtn.backgroundColor = [UIColor colorWithHexString:@"F8F8F8"];
    [botonBtn setTitle:@"取消" forState:UIControlStateNormal];
    [botonBtn setTitleColor:[UIColor colorWithHexString:@"FF666666"] forState:UIControlStateNormal];
    
    [self.bottenView addSubview:botonBtn];
    
    NSArray *imageArray = @[@"btn_pop_weixin",@"btn_pop_pengyouquan",@"btn_pop_weibo",@"btn_pop_copylink"];
    //       CGFloat shareWideth = (WIDTH - 68)/4;
    CGFloat shareWideth = (WIDTH - 194)/4;
    for (NSInteger i =0 ; i < 4; i ++){
        self.shareView = [[UIView alloc]initWithFrame:CGRectMake((42+shareWideth)*i+34,0 ,shareWideth ,  WIDTH * 0.46 - 50)];
        [self.bottenView addSubview:self.shareView];
        self.shareView.tag = i;
        self.shareView.userInteractionEnabled = YES;
        UITapGestureRecognizer *shareTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(shareActionMake:)];
        [self.shareView addGestureRecognizer:shareTap];
        
        UIImageView *shareImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 25,shareWideth,shareWideth)];
        [self.shareView addSubview:shareImage];
        UILabel *shareLabel = [[UILabel alloc]initWithFrame:CGRectMake(-10,shareWideth + 30, self.shareView.frame.size.width+20, 14)];
        shareLabel.textAlignment = NSTextAlignmentCenter;
        shareLabel.font = [UIFont systemFontOfSize:12];
        shareLabel.textColor = [UIColor colorWithHexString:@"999999"];
        [self.shareView addSubview:shareLabel];
        switch (i){
            case 0:
                shareImage.image = [UIImage imageNamed:imageArray[i]];
                shareLabel.text = @"微信好友";
                break;
            case 1:
                shareImage.image = [UIImage imageNamed:imageArray[i]];
                shareLabel.text = @"朋友圈";
                break;
            case 2:
                shareImage.image = [UIImage imageNamed:imageArray[i]];
                shareLabel.text = @"新浪微博";
                break;
            case 3:
                shareImage.image = [UIImage imageNamed:imageArray[i]];
                shareLabel.text = @"复制链接";
                break;
                
            default:
                break;
        }
    }
    UIView *lineView = [NSHelper createrViewFrame:CGRectMake(0, WIDTH * 0.46 - 50, WIDTH, 0.5) backColor:@"d9d9d9"];
    [self.bottenView addSubview:lineView];
}

- (void)shareActionMake:(UITapGestureRecognizer *)g{
    [UIView animateWithDuration:0.3 animations:^{
        self.bottenView.frame = CGRectMake(0, HEIGHT, WIDTH, WIDTH * 0.46);
    } completion:^(BOOL finished) {
        [self.view addSubview:self.footView];
        [self.coverView removeFromSuperview];
        
    }];
    
    NSInteger index = g.view.tag;
    UMSocialPlatformType shareType;
    
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    if (self.imageShar == nil) {
        self.imageShar = [UIImage imageNamed:@"icon-60"];
    }
    
    //创建网页内容对象
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:self.titleStr descr:self.countStr thumImage:self.imageShar];
    //设置网页地址
    shareObject.webpageUrl = self.url;
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    switch (index){
        case 0:{
            shareType = UMSocialPlatformType_WechatSession;
            break;
        }
        case 1:
            shareType = UMSocialPlatformType_WechatTimeLine;
            break;
        case 2:
            shareType = UMSocialPlatformType_Sina;//140个字
            break;
        case 3:{
            [self copyTextUrl];
            return;
        }
        default:
            break;
    }
    
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:shareType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            NSLog(@"************Share fail with error %@*********",error);
        }else{
            NSLog(@"response data is %@",data);
        }
    }];
}
#pragma mark ----------- 复制
- (void)copyTextUrl{
    [MBProgressHUD showSuccess:@"复制成功" toView:nil];
    UIPasteboard *generalPasteBoard = [UIPasteboard generalPasteboard];
    [generalPasteBoard setString:self.url];
}

- (void)customNavBackButtonClicked{
    if(self.webview.canGoBack){
        [self.webview goBack];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.mUrlArray.count;
}

/**
 *  通过下标获取图片
 */
- (id )photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    //创建图片模型
    NSURL *url = [NSURL URLWithString:self.mUrlArray[index]];
    MWPhoto *photo = [MWPhoto photoWithURL:url];
    return photo;
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ----------//UIWebview代理
- (void)webViewDidStartLoad:(UIWebView *)webView{
    if(self.hud == nil){
        self.hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    //预览图片
    if ([request.URL.scheme isEqualToString:@"image-preview"]) {
        NSString* path = [request.URL.absoluteString substringFromIndex:[@"image-preview:" length]];
        path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [self cretaerBrowser];
        //path 就是被点击图片的url
        for (NSInteger i = 0; i < self.mUrlArray.count; i++) {
            if ([path isEqualToString:self.mUrlArray[i]]) {
                [self.photo setCurrentPhotoIndex:i];
                break;
            }
        }
        [self.navigationController pushViewController:self.photo animated:YES];
        return NO;
    }
    if(navigationType == UIWebViewNavigationTypeLinkClicked){
        
        
        DetaileViewController *vc =[[DetaileViewController alloc]init];
        vc.url = request.URL.absoluteString;
        [self.navigationController pushViewController:vc animated:YES];
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
      self.mUrlArray = [NSMutableArray new];
    //这里是js，主要目的实现对url的获取
    static  NSString * const jsGetImages =
    @"function getImages(){\
    var objs = document.getElementsByTagName(\"img\");\
    var imgScr = '';\
    for(var i=0;i<objs.length;i++){\
    imgScr = imgScr + objs[i].src + '+';\
    };\
    return imgScr;\
    };";
    
    [webView stringByEvaluatingJavaScriptFromString:jsGetImages];//注入js方法
    NSString *urlResurlt = [webView stringByEvaluatingJavaScriptFromString:@"getImages()"];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[urlResurlt componentsSeparatedByString:@"+"]];
    for (NSInteger i = 0; i < array.count;i++) {
        if(array.count%2 == 0 && i==array.count/2){
            break;
        }
        NSString *url = array[i];
        if ([url hasSuffix:@"jpg"]||[url hasSuffix:@"png"]) {
            if (![self.mUrlArray containsObject:url]) {
                 [self.mUrlArray addObject:url];
            }
        }
    }
//添加图片可点击js
    [webView stringByEvaluatingJavaScriptFromString:@"function registerImageClickAction(){\
     var imgs=document.getElementsByTagName('img');\
     var length=imgs.length;\
     for(var i=0;i<length;i++){\
     img=imgs[i];\
     img.onclick=function(){\
     window.location.href='image-preview:'+this.src}\
     }\
     }"];
    [self.webview stringByEvaluatingJavaScriptFromString:@"registerImageClickAction();"];

    self.useID =  [self.webview stringByEvaluatingJavaScriptFromString:@"document.getElementById('guestuserid').value"];
    //分享标题
    self.titleStr = [self.webview stringByEvaluatingJavaScriptFromString:@"document.title"];
    //分享内容
    NSString *str = @"document.getElementById('metades').value";
    self.countStr = [webView stringByEvaluatingJavaScriptFromString:str];
    if (self.countStr.length > 140) {
        self.countStr = [self.countStr substringToIndex:140];
    }
    
    // 分享图片
    NSString *str1 = @"document.getElementById('imgshare').src";
    //   NSString *str = @"document.getElementById('shareImage');";
    NSString *pageSource1 = [webView stringByEvaluatingJavaScriptFromString:str1];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:pageSource1]];
    self.imageShar = [UIImage imageWithData:data];
    
    NSString *name =  [self.webview stringByEvaluatingJavaScriptFromString:@"document.getElementById('guestname').value"];
    if(self.title.length == 0){
        // 创建一个富文本
        NSMutableAttributedString * attriStr1 = [[NSMutableAttributedString alloc] initWithString:name];
        /**
         添加图片到指定的位置
         */
        NSTextAttachment *attchImage = [[NSTextAttachment alloc] init];
        
        // 表情图片
        attchImage.image =[self.imageShar roundedCornerImageWithCornerRadius:CGRectMake(0, 0, 24, 24)];
        
        // 设置图片大小
        attchImage.bounds = CGRectMake(-4, -4, 24, 24);
        NSAttributedString *stringImage = [NSAttributedString attributedStringWithAttachment:attchImage];
        [attriStr1 insertAttributedString:stringImage atIndex:0];
        if (attriStr1.length > 0 && self.useID.integerValue > 0) {
            [self.nameLabel addGestureRecognizer:self.tap];
        }
        self.nameLabel.attributedText = attriStr1;
    }
       [self.hud hideAnimated:YES];
    [self.view addSubview:self.footView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self.hud hideAnimated:YES];
}

- (void)cretaerBrowser{
    self.photo = [[MWPhotoBrowser alloc] initWithDelegate:self];
    self.photo.displayActionButton = YES;
    self.photo.displayNavArrows = YES;
    self.photo.displaySelectionButtons = NO;
    self.photo.alwaysShowControls = NO;
    self.photo.autoPlayOnAppear = NO;
    self.photo.zoomPhotosToFill = YES;
    self.photo.enableGrid = NO;
    self.photo.startOnGrid = NO;
    self.photo.enableSwipeToDismiss = YES;
}

@end
