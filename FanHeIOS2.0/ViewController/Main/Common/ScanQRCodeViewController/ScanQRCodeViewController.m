//
//  ScanQRCodeViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/11/25.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ScanQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ZBarCameraOverlayView.h"

@interface ScanQRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property(nonatomic)AVCaptureSession *session;

@end

@implementation ScanQRCodeViewController

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return NO;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect scanMarkFrame = CGRectMake(40, 120, WIDTH-2*40, WIDTH-2*40);
    ZBarCameraOverlayView *view = [[ZBarCameraOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds scanMaskFrame:scanMarkFrame];
    [self.view addSubview:view];
    [self startScaning];
    // Do any additional setup after loading the view.
}

- (void)startScaning{
    AVCaptureVideoPreviewLayer *layer = [self creatCaptureDevice:CGRectMake(0, 0, WIDTH, HEIGHT) viewSize:CGRectMake(0, 0, WIDTH, HEIGHT)];
    [self.view.layer insertSublayer:layer atIndex:0];
}

- (AVCaptureVideoPreviewLayer *)creatCaptureDevice:(CGRect)windowSize viewSize:(CGRect)viewSize{
    //获取摄像设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    if (!input) return nil;
    //创建输出流
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc]init];
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //设置有效扫描区域
    CGRect scanCrop=[self getScanCrop:windowSize readerViewBounds:viewSize];
    output.rectOfInterest = scanCrop;
    //初始化链接对象
    _session = [[AVCaptureSession alloc]init];
    //高质量采集率
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    [_session addInput:input];
    [_session addOutput:output];
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    layer.frame=viewSize;
    //    [self.view.layer insertSublayer:layer atIndex:0];
    //开始捕获
    [_session startRunning];
    
    return layer;
}

#pragma mark-> 获取扫描区域的比例关系
-(CGRect)getScanCrop:(CGRect)rect readerViewBounds:(CGRect)readerViewBounds{
    CGFloat x,y,width,height;
    x = (CGRectGetHeight(readerViewBounds)-CGRectGetHeight(rect))/2/CGRectGetHeight(readerViewBounds);
    y = (CGRectGetWidth(readerViewBounds)-CGRectGetWidth(rect))/2/CGRectGetWidth(readerViewBounds);
    width = CGRectGetHeight(rect)/CGRectGetHeight(readerViewBounds);
    height = CGRectGetWidth(rect)/CGRectGetWidth(readerViewBounds);
    return CGRectMake(x, y, width, height);
}

#pragma mark 输出的代理
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {
        [_session stopRunning];
        [self.navigationController popViewControllerAnimated:NO];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0];
        if(self.delegate && [self.delegate respondsToSelector:@selector(ScanQRCodeViewControllerDelegateResult:)]){
            [self.delegate ScanQRCodeViewControllerDelegateResult:metadataObject.stringValue];
        }
    }
}

@end
