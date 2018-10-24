//
//  CropImageViewController.m
//  crop
//
//  Created by ddapp on 16/4/1.
//  Copyright © 2016年 techinone. All rights reserved.
//

#import "CropImageViewController.h"
#import "myView.h"
#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

typedef NS_ENUM(NSUInteger, ActionViewTag) {
    OriginViewTag = 111,
    CropViewTag
};

static CGPoint PreviousTapPoint = (CGPoint){0,0};
//记录图片最小的缩放大小
static  CGSize originImageViewSmallSize = (CGSize){0,0};
//记录图片最大的缩放大小
static  CGSize originImageViewBigestSize = (CGSize){0,0};

static CGAffineTransform PreviousAffineTransform = (CGAffineTransform){1,0,0,1,0,0};

@interface CropImageViewController () <UIGestureRecognizerDelegate,btnActionDelegate>{
    CGSize kCropViewDefaultSize;
}
@property (copy, nonatomic) CropedImageCallBack callBack;

@property (strong, nonatomic) UIImage *originImage;

@property (strong, nonatomic, readonly) UIImage *generateCropImage;

@property (strong, nonatomic) UIView *originImageBoardView;

@property (strong, nonatomic) UIImageView *originImageView;

@property (strong, nonatomic) UIView *cropView;

@property (strong, nonatomic) UIButton *cropButton;

@property(nonatomic,strong)UIView * shadeView;

@property(nonatomic,strong)myView * sureMyView;

@property(nonatomic,assign)CGRect  cropRect;

@property(nonatomic,assign)CGPoint imageOriginCenter;

@end

@implementation CropImageViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    self.shadeView.hidden = NO;
}

- (instancetype)initWithOriginImage:(UIImage *)originImage callBack:(CropedImageCallBack)callBack{
    assert(originImage && callBack);
    if(self = [super init]) {
        kCropViewDefaultSize= CGSizeMake(WIDTH,(WIDTH*9/16.0));
        self.callBack = callBack;
        self.originImage = originImage;
    }else{
        return nil;
    }
    return self;
}

- (instancetype)init {
    NSAssert(0, @"use initWithOriginImage:callBack: instead");
    return nil;
}

#pragma mark bind gesture recognizer
- (void)bindGestureAction {
    UIPinchGestureRecognizer *pinchOriginGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureAction:)];
    
    UIPanGestureRecognizer *panOriginGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    
    panOriginGestureRecognizer.maximumNumberOfTouches = 1;
    
    UIRotationGestureRecognizer *rotationOriginGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationGestureAction:)];
    
    pinchOriginGestureRecognizer.delegate = panOriginGestureRecognizer.delegate = rotationOriginGestureRecognizer.delegate = self;
    
    [self.originImageBoardView addGestureRecognizer:pinchOriginGestureRecognizer];
    [self.originImageBoardView addGestureRecognizer:panOriginGestureRecognizer];
    
    panOriginGestureRecognizer.maximumNumberOfTouches = 1;
    if(self.isFixCropSize) {
        return;
    }
}

#pragma mark relayout subviews

- (void)generateSubViews {
    self.view.backgroundColor = [UIColor whiteColor];
    
//    generate origin imageview background view;
    
    self.originImageBoardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT - 40)];
    self.originImageBoardView.tag = OriginViewTag;
    self.originImageBoardView.clipsToBounds = YES;
    self.originImageBoardView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.originImageBoardView];
    
//    generate origin imageview
    
    self.originImageView = [[UIImageView alloc] init];
    
    [self.originImageBoardView addSubview:self.originImageView];
    
    if (self.originImage.size.width <= kCropViewDefaultSize.width || self.originImage.size.height <= kCropViewDefaultSize.height) {
        self.originImageView.frame = CGRectMake(0, 0,kCropViewDefaultSize.width, kCropViewDefaultSize.height);
    }
    if (self.originImage.size.width > self.originImage.size.height) {
        self.originImageView.frame = CGRectMake(0, 0,kCropViewDefaultSize.height *  self.originImage.size.width / self.originImage.size.height, kCropViewDefaultSize.height);
    }else{
         self.originImageView.frame = CGRectMake(0, 0,kCropViewDefaultSize.width,kCropViewDefaultSize.width * self.originImage.size.height / self.originImage.size.width);
    }
    originImageViewSmallSize = CGSizeMake(self.originImageView.frame.size.width, self.originImageView.frame.size.height);
    
    originImageViewBigestSize = CGSizeMake(self.originImage.size.width * 2, self.originImage.size.height * 2);
    
    self.originImageView.center = self.originImageBoardView.center;
    
    self.originImageView.image = self.originImage;
    
    
//    generate crop view
    self.cropView = [[UIView alloc] init];
    
    self.cropView.center = self.originImageBoardView.center;
    
    if(CGSizeEqualToSize(self.cropSize, CGSizeZero)) {
        self.cropView.bounds = CGRectMake(0, 0, kCropViewDefaultSize.width, kCropViewDefaultSize.height);
    }else{
        self.cropView.bounds = CGRectMake(0, 0, self.cropSize.width, self.cropSize.height);
    }
    
    self.cropView.tag = CropViewTag;
    
    self.cropView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:.5];
    [self.originImageBoardView  addSubview:self.cropView];
    self.cropView.hidden = YES;
    
    self.shadeView = [[UIView alloc] initWithFrame:self.originImageBoardView.bounds];
    
    self.shadeView.alpha = 0.8;
    
    [self.originImageBoardView addSubview:self.shadeView];
    
    self.shadeView.center = self.originImageBoardView.center;
    
//    generate crop button;
    if (!self.sureMyView) {
        self.sureMyView = [[[NSBundle mainBundle] loadNibNamed:@"myView" owner:self options:nil]lastObject];
    }
    
    self.sureMyView.frame = CGRectMake(0, SCREENHEIGHT - 40, SCREENWIDTH, 40);
    
    [self.view addSubview:self.sureMyView];
    
    self.sureMyView.myViewDelegate = self;
}
/**
 *  添加了滤镜
 *
 *  @param backView 蒙版的VIEW
 *  @param rect     滤镜圆形宽
 */
- (void)getView:(UIView *)backView withRect:(CGRect) rect{
    int radius = 0;//kCropViewDefaultSize.width/2.0;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:backView.frame cornerRadius:0];
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    [path appendPath:circlePath];
    [path setUsesEvenOddFillRule:YES];
    CAShapeLayer *fillLayer = [CAShapeLayer  layer];
    fillLayer.path = path.CGPath;
    fillLayer.fillRule =kCAFillRuleEvenOdd;
    fillLayer.fillColor = [UIColor  blackColor].CGColor;
    fillLayer.opacity =0.5;
    [backView.layer  addSublayer:fillLayer];
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self generateSubViews];
    
    [self bindGestureAction];
    
    [self  getView:self.shadeView withRect:self.cropView.frame];
}

#pragma mark gesture recognizer action

- (void)pinchGestureAction:(UIPinchGestureRecognizer *)gestureRecognizer {
    
    UIView *gestureView = gestureRecognizer.view;
    
    if(gestureView.tag == OriginViewTag) {
        
        gestureView = self.originImageView;
        
    }
    
    CGAffineTransform affineTransform = CGAffineTransformScale(gestureView.transform,gestureRecognizer.scale, gestureRecognizer.scale);
    
    gestureView.transform = affineTransform;
    
    gestureRecognizer.scale = 1;
    
    if(gestureRecognizer.view.tag == OriginViewTag) {
        
        
     NSLog(@"放大缩放之后的图片坐标:%@",NSStringFromCGRect(self.originImageView.frame));
        
     if (self.originImageView.frame.size.width <= originImageViewSmallSize.width || self.originImageView.frame.size.height <= originImageViewSmallSize.height){
         
         self.originImageView.frame = CGRectMake(self.originImageView.frame.origin.x, self.originImageView.frame.origin.y,originImageViewSmallSize.width, originImageViewSmallSize.height);
         
    }
        
    if (self.originImageView.frame.size.width >= originImageViewBigestSize.width || self.originImageView.frame.size.height >= originImageViewBigestSize.height) {
            
        self.originImageView.frame = CGRectMake(self.originImageView.frame.origin.x, self.originImageView.frame.origin.y,originImageViewBigestSize.width, originImageViewBigestSize.height);
            
            
    }
        
        
        
    if (self.originImageView.frame.origin.x >= self.cropView.frame.origin.x ) {
            
            
            self.originImageView.frame = CGRectMake(self.cropView.frame.origin.x, self.originImageView.frame.origin.y, self.originImageView.frame.size.width, self.originImageView.frame.size.height);
            
        }
        
        
    if (self.cropView.frame.origin.x + 200 - self.originImageView.frame.size.width >= self.originImageView.frame.origin.x) {
            
            
            self.originImageView.frame = CGRectMake(self.cropView.frame.origin.x + 200 - self.originImageView.frame.size.width, self.originImageView.frame.origin.y, self.originImageView.frame.size.width, self.originImageView.frame.size.height);
        }
        
    if (self.originImageView.frame.origin.y >= self.cropView.frame.origin.y){
            
            self.originImageView.frame = CGRectMake(self.originImageView.frame.origin.x,self.cropView.frame.origin.y,self.originImageView.frame.size.width, self.originImageView.frame.size.height);
            
        }
        
    if (self.cropView.frame.origin.y + 200 - self.originImageView.frame.size.height >= self.originImageView.frame.origin.y) {
            
            
            self.originImageView.frame = CGRectMake(self.originImageView.frame.origin.x,self.cropView.frame.origin.y + 200 - self.originImageView.frame.size.height , self.originImageView.frame.size.width, self.originImageView.frame.size.height);
            
        }
        
        
        return;
    }
    
    if(!CGRectContainsRect(self.originImageBoardView.frame, gestureView.frame)) {
        
        gestureView.transform = PreviousAffineTransform;
        
        return;
    }
    
    PreviousAffineTransform = gestureView.transform;
    
   
}

- (void)panGestureAction:(UIPanGestureRecognizer *)gestureRecognizer {
    
    UIView *gestureView = gestureRecognizer.view,
    
    *gestureViewSuperView = gestureView.superview;
    
    BOOL needPaddingDistance = NO;
    
    if(gestureView.tag == OriginViewTag) {
        
        gestureView = self.originImageView;
        
        needPaddingDistance = NO;
        
    }
    else if (gestureView.tag == CropViewTag) {
        
        needPaddingDistance = YES;
        
        gestureViewSuperView = self.originImageBoardView;
        
    }
    
    CGPoint touchPoint = [gestureRecognizer locationInView:gestureView.superview];
    
    if(gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint centerPoint = CGPointMake(gestureView.center.x + touchPoint.x - PreviousTapPoint.x, gestureView.center.y + touchPoint.y - PreviousTapPoint.y);
     
        
        if(needPaddingDistance) {
            CGFloat w = CGRectGetWidth(gestureView.frame),
            h = CGRectGetHeight(gestureView.frame);
            CGRect tempFrame = CGRectMake(centerPoint.x - w / 2, centerPoint.y - h / 2, w, h);
            if(!CGRectContainsRect(gestureViewSuperView.frame, tempFrame)) {
                return;
            }
        }
        
        gestureView.center = centerPoint;
        
        
        
        if (self.originImageView.frame.origin.x >= self.cropView.frame.origin.x  ) {
            
            
            self.originImageView.frame = CGRectMake(self.cropView.frame.origin.x, self.originImageView.frame.origin.y, self.originImageView.frame.size.width, self.originImageView.frame.size.height);
            
        }
        
        
        if (self.cropView.frame.origin.x + 200 - self.originImageView.frame.size.width >= self.originImageView.frame.origin.x) {
            
            
            self.originImageView.frame = CGRectMake(self.cropView.frame.origin.x + 200 - self.originImageView.frame.size.width, self.originImageView.frame.origin.y, self.originImageView.frame.size.width, self.originImageView.frame.size.height);
        }
        
        if (self.originImageView.frame.origin.y >= self.cropView.frame.origin.y){
            
             self.originImageView.frame = CGRectMake(self.originImageView.frame.origin.x,self.cropView.frame.origin.y,self.originImageView.frame.size.width, self.originImageView.frame.size.height);
            
        }
        
        if (self.cropView.frame.origin.y + 200 - self.originImageView.frame.size.height >= self.originImageView.frame.origin.y) {
            
            
            self.originImageView.frame = CGRectMake(self.originImageView.frame.origin.x,self.cropView.frame.origin.y + 200 - self.originImageView.frame.size.height , self.originImageView.frame.size.width, self.originImageView.frame.size.height);
            
        }

    
        
    }
    
    
    PreviousTapPoint = touchPoint;
    
    [gestureRecognizer setTranslation:CGPointZero inView:gestureView.superview];
}

- (void)rotationGestureAction:(UIRotationGestureRecognizer *)gestureRecognizer {
    UIView *gestureView = gestureRecognizer.view;
    if(gestureView.tag == OriginViewTag) {
        gestureView = self.originImageView;
    }
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        PreviousTapPoint = gestureView.center;
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan || gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        gestureView.transform = CGAffineTransformRotate(gestureView.transform, gestureRecognizer.rotation);
        gestureView.center = PreviousTapPoint;
        [gestureRecognizer setRotation:0];
    }
}

- (UIImage *)generateCropImage {
    
    self.shadeView.hidden = YES;
    
    UIGraphicsBeginImageContext(self.originImageBoardView.bounds.size); //currentView 当前的view
    [self.originImageBoardView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *originFullImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    CGImageRef imageRef = originFullImage.CGImage;
    CGImageRef imagePartRef = CGImageCreateWithImageInRect(imageRef, self.cropView.frame);
    UIImage *cropImage = [UIImage imageWithCGImage:imagePartRef];
    CGImageRelease(imagePartRef);
    
    return cropImage;
}

- (void)btnActionWithTag:(NSInteger)btnTag
{
    if (btnTag == 102) {
        
        
        NSArray * viewControllsArray = [self.navigationController viewControllers];
        
        if (viewControllsArray.count > 1) {
            

            if ([viewControllsArray  objectAtIndex:viewControllsArray.count - 1] == self) {
                
               [self.navigationController  popViewControllerAnimated:YES];
                
            }
            
        }else{
            
             [self  dismissViewControllerAnimated:YES completion:nil];
        }
        
        
    }else if (btnTag == 101){
        
        if(self.callBack) {
            
            self.callBack(self.generateCropImage,self);
            
        }
        
    }
}


#pragma mark UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    
    return YES;
}

#pragma mark - 压缩图片
- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
