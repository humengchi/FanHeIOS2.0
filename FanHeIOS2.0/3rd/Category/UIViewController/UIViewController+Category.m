//
//  UIViewController+Category.m
//  ChannelPlus
//
//  Created by Peter on 14/12/20.
//  Copyright (c) 2014年 Peter. All rights reserved.
//

#import "UIViewController+Category.h"

@implementation UIViewController (Category)
/*
// 获取当前界面viewController
- (UIViewController *)viewController {
    UIResponder *responder = self;
    while (![responder isKindOfClass:[UIViewController class]]) {
        responder = [responder nextResponder];
        if (nil == responder) {
            break;
        }
    }
    return (UIViewController *)responder;
}

// 竖屏-->横屏、横屏-->竖屏 可以旋转，其他情况禁止旋转
- (BOOL)shouldAutorotate {
//    UIViewController *vc = [self viewController];
//    NSString *viewControllerClassName = [NSString stringWithUTF8String:object_getClassName(vc)];
    
    BOOL isLandscapeOrientation = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
//    if ([viewControllerClassName isEqualToString:@"JDSideMenu"] //|| [viewControllerClassName isEqualToString:@"RDVTabBarController"]) {//JDSideMenu控制器
        BOOL defaultLandscape = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaults_defaultLandscape];
        if(!isLandscapeOrientation && defaultLandscape){//竖屏-->横屏
            return YES;
        }else if(isLandscapeOrientation && !defaultLandscape){//横屏-->竖屏
            return YES;
        }else{
            return NO;
        }
//    }else{
//        return NO;
//    }
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskLandscapeRight;
}*/


/*
// IOS5默认支持竖屏
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
// IOS6默认不开启旋转，如果subclass需要支持屏幕旋转，重写这个方法return YES即可
- (BOOL)shouldAutorotate {
    return NO;
}
// IOS6默认支持竖屏
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
*/
- (UIButton *)intTwoNavBarRight:(CGRect)rect oneImageName:(NSString *)oneImageName oneButtonName:(NSString *)oneButtonName twoImageName:(NSString *)twoImageName twoButtonName:(NSString *)twoButtonName{
    
    UIView *view = [[UIView alloc]initWithFrame:rect];
    view.userInteractionEnabled = YES;
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(14, 0, view.frame.size.width/2, view.frame.size.height);
    [btn1 setTitle:oneButtonName forState:UIControlStateNormal];
    [btn1 setImage:[UIImage imageNamed:oneImageName] forState:UIControlStateNormal];
    
     [btn1 addTarget:self action:@selector(oneRigthUpAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn1];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(view.frame.size.width/2+10,0, view.frame.size.width/2, view.frame.size.height);
    [btn2 setTitle:twoButtonName forState:UIControlStateNormal];
    [btn2 setImage:[UIImage imageNamed:twoImageName] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(twoRigthUpAction:) forControlEvents:UIControlEventTouchUpInside];
//    btn2.imageEdgeInsets = UIEdgeInsetsMake(-2, 0, 0, 0);
    [view addSubview:btn2];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:view];
    self.navigationItem.rightBarButtonItem = backBarButton;
    return btn2;
}
- (void)oneRigthUpAction:(UIButton *)btn
{
    
}
- (void)twoRigthUpAction:(UIButton *)btn
{
    
}
- (UIButton *)intNavBarRight:(CGRect)rect imageName:(NSString *)imageName buttonName:(NSString *)buttonName {
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = rect;
    [backButton.titleLabel setFont:FONT_SYSTEM_SIZE(17)];
    
    if (buttonName)
        [backButton setTitle:buttonName forState:UIControlStateNormal];
    
    if (imageName)
        [backButton setImage:kImageWithName(imageName) forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(rightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.rightBarButtonItem = backBarButton;
    
    self.navigationController.navigationBar.tintColor = WHITE_COLOR;
//    self.navigationController.navigationBar.barTintColor = kColorDefault;
    
    return backButton;
}

- (UIButton *)intNavBarButtonItem:(BOOL)right frame:(CGRect)rect imageName:(NSString *)imageName buttonName:(NSString *)buttonName{
    UIButton *barButton = [UIButton buttonWithType:UIButtonTypeCustom];
    barButton.frame = rect;
    [barButton.titleLabel setFont:FONT_SYSTEM_SIZE(15)];
    
    if (buttonName.length)
        [barButton setTitle:buttonName forState:UIControlStateNormal];
    
    if (imageName.length){
        [barButton setImage:kImageWithName(imageName) forState:UIControlStateNormal];
    }
    
    if(!right){
        [barButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [barButton addTarget:self action:@selector(leftButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:barButton];
        self.navigationItem.leftBarButtonItem = backBarButton;
    }else{
        [barButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        barButton.titleLabel.textAlignment = NSTextAlignmentRight;
        [barButton addTarget:self action:@selector(rightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:barButton];
        self.navigationItem.rightBarButtonItem = backBarButton;
    }
    return barButton;
}

- (void)leftButtonClicked:(UIButton*)sender{
    [self newThreadForAvoidButtonRepeatClick:sender];
}

- (void)rightButtonClicked:(id)sender {
    [self newThreadForAvoidButtonRepeatClick:sender];
}

- (void)initSpaceLeftNavBar{
    UIButton *barButton = [UIButton buttonWithType:UIButtonTypeCustom];
    barButton.frame = CGRectMake(0, 0, 0, 0);
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:barButton];
    self.navigationItem.leftBarButtonItem = backBarButton;
}

-(void)initDefaultLeftNavbar {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:kImageWithName(@"navBack") landscapeImagePhone:kImageWithName(@"navBack") style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonClicked:)];
    self.navigationItem.leftBarButtonItem =item;
}

- (void)backButtonClicked:(id)sender {
    [self newThreadForAvoidButtonRepeatClick:sender];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)avoidButtonRepeatClick:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        button.userInteractionEnabled = NO;
        sleep(1.f);
        button.userInteractionEnabled = YES;
    }
}

- (void)newThreadForAvoidButtonRepeatClick:(id)sender {
    if (sender!=nil) {
        //防止按钮重复点击
        [NSThread detachNewThreadSelector:@selector(avoidButtonRepeatClick:) toTarget:self withObject:sender];
    }
}

//主页
- (void)initHomeBarButtonItem{
    UIButton *barButton = [UIButton buttonWithType:UIButtonTypeCustom];
    barButton.frame = CGRectMake(0, 0, 18, 18);
    [barButton.titleLabel setFont:FONT_SYSTEM_SIZE(17)];
    [barButton setBackgroundImage:kImageWithName(@"home_Btn") forState:UIControlStateNormal];
    [barButton addTarget:self action:@selector(backHomeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:barButton];
    self.navigationItem.leftBarButtonItem = backBarButton;
    self.navigationController.navigationBar.tintColor = WHITE_COLOR;
}

//返回主页
- (void)backHomeButtonClicked:(UIButton*)sender{
    [self newThreadForAvoidButtonRepeatClick:sender];
}

-(NSString*)getUUID {
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    return result;
}

//照片获取本地路径转换
- (NSString *)getImagePath:(UIImage *)image {
    NSData *data = UIImageJPEGRepresentation(image, 1);
    //这里将图片放在沙盒的documents文件夹中
    NSString *DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/dynamic"];
    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //把刚刚图片转换的data对象拷贝至沙盒中
    [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *ImagePath = [[NSString alloc] initWithFormat:@"%@.png",[self getUUID]];
    [fileManager createFileAtPath:[NSString stringWithFormat:@"%@/%@", DocumentsPath, ImagePath] contents:data attributes:nil];
    return ImagePath;
}


@end
