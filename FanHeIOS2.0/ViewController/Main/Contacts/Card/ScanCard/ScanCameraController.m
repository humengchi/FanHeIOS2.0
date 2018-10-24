//
//  ScanCameraController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/14.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ScanCameraController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ScanCardViewController.h"

typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);


@interface ScanCameraController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong,nonatomic) AVCaptureSession *captureSession;//负责输入和输出设置之间的数据传递
@property (strong,nonatomic) AVCaptureDeviceInput *captureDeviceInput;//负责从AVCaptureDevice获得输入数据
@property (strong,nonatomic) AVCaptureStillImageOutput *captureStillImageOutput;//照片输出流
@property (strong,nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;//相机拍摄预览图层
@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UIButton *takeButton;//拍照按钮
@property (weak, nonatomic) IBOutlet UIButton *flashButton;//选择闪光灯按钮
@property (weak, nonatomic) IBOutlet UIButton *flashAutoButton;//自动闪光灯按钮
@property (weak, nonatomic) IBOutlet UIButton *flashOnButton;//打开闪光灯按钮
@property (weak, nonatomic) IBOutlet UIButton *flashOffButton;//关闭闪光灯按钮
@property (weak, nonatomic) IBOutlet UIImageView *focusCursor; //聚焦光标

@end

@implementation ScanCameraController

// 作用：拦截手势触发
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BLACK_COLOR;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if(granted){
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"请在iPhone的“设置>隐私>相机”选项中，允许3号圈访问你的相机" cancelButtonTitle:@"取消" otherButtonTitle:@"设置" cancle:^{
                    [self.navigationController popViewControllerAnimated:YES];
                } confirm:^{
                    if(IOS_X >= 10){
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }else{
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy"]];
                    }
                }];
            });
            return;
        }
    }];
    //初始化会话
    _captureSession=[[AVCaptureSession alloc] init];
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        //设置分辨率,1280x720, 图片的旋转方向是向右
        _captureSession.sessionPreset=AVCaptureSessionPreset1280x720;
    }
    
    //获得输入设备
    AVCaptureDevice *captureDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];//取得后置摄像头
    if (!captureDevice) {
        NSLog(@"取得后置摄像头时出现问题.");
        return;
    }
    
    //根据输入设备初始化设备输入对象，用于获得输入数据
    NSError *error=nil;
    _captureDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:captureDevice error:&error];
    if (error) {
        NSLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        return;
    }
    
    //初始化设备输出对象，用于获得输出数据
    _captureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = @{AVVideoWidthKey : @(WIDTH),AVVideoHeightKey: @(HEIGHT-132),AVVideoCodecKey:AVVideoCodecJPEG};
    [_captureStillImageOutput setOutputSettings:outputSettings];//输出设置
    
    //将设备输入添加到会话中
    if ([_captureSession canAddInput:_captureDeviceInput]) {
        [_captureSession addInput:_captureDeviceInput];
    }
    
    //将设备输出添加到会话中
    if ([_captureSession canAddOutput:_captureStillImageOutput]) {
        [_captureSession addOutput:_captureStillImageOutput];
    }
    
    //创建视频预览层，用于实时展示摄像头状态
    _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    
    CALayer *layer = self.viewContainer.layer;
    layer.masksToBounds = YES;
    
    _captureVideoPreviewLayer.frame = CGRectMake(0, 0, WIDTH, HEIGHT-132);
    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//填充模式
    //将视频预览层添加到界面中
//    [layer addSublayer:_captureVideoPreviewLayer];
    [layer insertSublayer:_captureVideoPreviewLayer below:self.focusCursor.layer];
    
    [self addNotificationToCaptureDevice:captureDevice];
    [self addGenstureRecognizer];
    [self setFlashModeButtonStatus];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(self.captureSession){
        [self.captureSession startRunning];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if(self.captureSession){
        [self.captureSession stopRunning];
    }
    [self removeNotification];
}

- (void)dealloc{
    [self removeNotification];
}

#pragma mark - 获取图片跳转到扫面结果页面 
- (void)gotoScanCardVC:(UIImage*)image{
    ScanCardViewController *vc = [CommonMethod getVCFromNib:[ScanCardViewController class]];
    vc.imageData = image;
    vc.isMyCard = self.isMyCard;
    vc.isRegister = self.isRegister;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:vc animated:YES];
    });
}

#pragma mark - UI按钮方法
#pragma mark 拍照
- (IBAction)takeButtonClick:(UIButton *)sender {
    //根据设备输出获得连接
    AVCaptureConnection *captureConnection = [self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    //根据连接取得设备输出的数据
    [self.captureStillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer,NSError *error) {
        if (imageDataSampleBuffer) {
            NSData *imageData=[AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
            //保存到手机相册
//            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            [self gotoScanCardVC:[self scaleImage:[UIImage fixOrientation:image]]];
        }
        
    }];
}

#pragma mark 选择闪光灯
- (IBAction)flashChoiceClick:(UIButton *)sender {
    BOOL isShow = !self.flashAutoButton.hidden;
    self.flashOnButton.hidden = isShow;
    self.flashOffButton.hidden = isShow;
    self.flashAutoButton.hidden = isShow;
}

#pragma mark 自动闪光灯开启
- (IBAction)flashAutoClick:(UIButton *)sender {
    [self setFlashMode:AVCaptureFlashModeAuto];
    [self setFlashModeButtonStatus];
}

#pragma mark 打开闪光灯
- (IBAction)flashOnClick:(UIButton *)sender {
    [self setFlashMode:AVCaptureFlashModeOn];
    [self setFlashModeButtonStatus];
}

#pragma mark 关闭闪光灯
- (IBAction)flashOffClick:(UIButton *)sender {
    [self setFlashMode:AVCaptureFlashModeOff];
    [self setFlashModeButtonStatus];
}

#pragma mark 取消
- (IBAction)navBackClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark 相册
- (IBAction)photoClick:(UIButton *)sender {
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == kCLAuthorizationStatusRestricted || author ==kCLAuthorizationStatusDenied){
        [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"请在iPhone的“设置>隐私>相册”选项中，允许3号圈访问你的相册" cancelButtonTitle:@"取消" otherButtonTitle:@"设置" cancle:^{
        } confirm:^{
            if(IOS_X >= 10){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }else{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy"]];
            }
        }];
        return;
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    UIImagePickerController *ctrl = [[UIImagePickerController alloc] init];
    ctrl.delegate = self;
    [self setNavigationBar_white];
    ctrl.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    [self presentViewController:ctrl animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

- (UIImage*)scaleImage:(UIImage*)originImage{
    CGSize retSize = originImage.size;
    CGFloat sizeWidth = retSize.width;
    CGFloat sizeHeight = sizeWidth*(HEIGHT-132)/WIDTH;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([originImage CGImage], CGRectMake(0, (retSize.height-sizeHeight)/2, sizeWidth, sizeHeight));//获取图片整体部分
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:originImage.scale orientation:UIImageOrientationUp];
    return image;
}

#pragma mark -- UIImagePickerControllerDelegate
//点击相册中的图片 货照相机照完后点击use  后触发的方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self setNavigationBar_kdefaultColor];
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    [self gotoScanCardVC:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//点击cancel 调用的方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self setNavigationBar_kdefaultColor];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 通知 给输入设备添加通知
-(void)addNotificationToCaptureDevice:(AVCaptureDevice *)captureDevice{
    //注意添加区域改变捕获通知必须首先设置设备允许捕获
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        captureDevice.subjectAreaChangeMonitoringEnabled=YES;
    }];
    //捕获区域发生改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(areaChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}

#pragma mark - 移除所有通知
-(void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)addNotificationToCaptureSession:(AVCaptureSession *)captureSession{
    //会话出错
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:captureSession];
}
/**
 *  设备连接成功
 *
 *  @param notification 通知对象
 */
-(void)deviceConnected:(NSNotification *)notification{
    NSLog(@"设备已连接...");
}
/**
 *  设备连接断开
 *
 *  @param notification 通知对象
 */
-(void)deviceDisconnected:(NSNotification *)notification{
    NSLog(@"设备已断开.");
}
/**
 *  捕获区域改变
 *
 *  @param notification 通知对象
 */
-(void)areaChange:(NSNotification *)notification{
    NSLog(@"捕获区域改变...");
}
/**
 *  会话出错
 *
 *  @param notification 通知对象
 */
- (void)sessionRuntimeError:(NSNotification *)notification{
    NSLog(@"会话发生错误.");
}

#pragma mark - 私有方法
/**
 *  取得指定位置的摄像头
 *
 *  @param position 摄像头位置
 *
 *  @return 摄像头设备
 */
- (AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position]==position) {
            return camera;
        }
    }
    return nil;
}

/**
 *  改变设备属性的统一操作方法
 *
 *  @param propertyChange 属性改变操作
 */
- (void)changeDeviceProperty:(PropertyChangeBlock)propertyChange{
    AVCaptureDevice *captureDevice = [self.captureDeviceInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}
/**
 *  设置闪光灯模式
 *
 *  @param flashMode 闪光灯模式
 */
- (void)setFlashMode:(AVCaptureFlashMode )flashMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFlashModeSupported:flashMode]) {
            [captureDevice setFlashMode:flashMode];
        }
    }];
}
/**
 *  设置聚焦模式
 *
 *  @param focusMode 聚焦模式
 */
- (void)setFocusMode:(AVCaptureFocusMode )focusMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:focusMode];
        }
    }];
}
/**
 *  设置曝光模式
 *
 *  @param exposureMode 曝光模式
 */
- (void)setExposureMode:(AVCaptureExposureMode)exposureMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:exposureMode];
        }
    }];
}
/**
 *  设置聚焦点
 *
 *  @param point 聚焦点
 */
- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
    }];
}

/**
 *  添加点按手势，点按时聚焦
 */
- (void)addGenstureRecognizer{
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScreen:)];
    [self.viewContainer addGestureRecognizer:tapGesture];
}

- (void)tapScreen:(UITapGestureRecognizer *)tapGesture{
    CGPoint point= [tapGesture locationInView:self.viewContainer];
    //将UI坐标转化为摄像头坐标
    CGPoint cameraPoint= [self.captureVideoPreviewLayer captureDevicePointOfInterestForPoint:point];
    [self setFocusCursorWithPoint:point];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}

/**
 *  设置闪光灯按钮状态
 */
- (void)setFlashModeButtonStatus{
    AVCaptureDevice *captureDevice = [self.captureDeviceInput device];
    AVCaptureFlashMode flashMode=captureDevice.flashMode;
    if([captureDevice isFlashAvailable]){
        self.flashAutoButton.hidden = YES;
        self.flashOnButton.hidden = YES;
        self.flashOffButton.hidden = YES;
        self.flashAutoButton.selected = NO;
        self.flashOnButton.selected = NO;
        self.flashOffButton.selected = NO;
        switch (flashMode) {
            case AVCaptureFlashModeAuto:
                self.flashAutoButton.selected = YES;
                [self.flashButton setImage:kImageWithName(@"btn_smmp_flashauto") forState:UIControlStateNormal];
                break;
            case AVCaptureFlashModeOn:
                self.flashOnButton.selected = YES;
                [self.flashButton setImage:kImageWithName(@"btn_smmp_flashopen") forState:UIControlStateNormal];
                break;
            case AVCaptureFlashModeOff:
                self.flashOffButton.selected = YES;
                [self.flashButton setImage:kImageWithName(@"btn_smmp_flashclose") forState:UIControlStateNormal];
                break;
            default:
                break;
        }
    }else{
        self.flashAutoButton.hidden=YES;
        self.flashOnButton.hidden=YES;
        self.flashOffButton.hidden=YES;
    }
}

/**
 *  设置聚焦光标位置
 *
 *  @param point 光标位置
 */
- (void)setFocusCursorWithPoint:(CGPoint)point{
    self.focusCursor.center = point;
    self.focusCursor.transform = CGAffineTransformMakeScale(1.5, 1.5);
    self.focusCursor.alpha = 1.0;
    [UIView animateWithDuration:1.0 animations:^{
        self.focusCursor.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.focusCursor.alpha = 0;
        
    }];
}

@end
