//
//  MBProgressHUD+Add.m
//  视频客户端
//
//  Created by mj on 13-4-18.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MBProgressHUD+Add.h"

@implementation MBProgressHUD (Add)

#pragma mark 显示信息
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view{
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = text;
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    [hud.button removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
    // 1秒之后再消失
    [hud hideAnimated:YES afterDelay:1.5];
}

#pragma mark 显示错误信息
+ (void)showError:(NSString *)error toView:(UIView *)view{
    [self show:error icon:@"error.png" view:view];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)view{
    [self show:success icon:@"success.png" view:view];
}

#pragma mark 显示一些信息
+ (MBProgressHUD *)showMessag:(NSString *)message toView:(UIView *)view {
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
  
    hud.label.text = message;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    [hud.button removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
    // YES代表需要蒙版效果
//    hud.dimBackground = YES;
    return hud;
}

#pragma mark- 自定义的显示加载
+ (void)showProgressHudImageViewToView:(UIView *)view{
    if([view viewWithTag:1111]){
        [[view viewWithTag:1111] removeFromSuperview];
    }
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    imageView.tag = 1111;
    [imageView setAnimationImages:@[kImageWithName(@"loading_toutiao_p1"),kImageWithName(@"loading_toutiao_p2"),kImageWithName(@"loading_toutiao_p3"),kImageWithName(@"loading_toutiao_p1")]];
    [imageView setAnimationDuration:0.8];
    [imageView setAnimationRepeatCount:-1];
    [imageView startAnimating];
    imageView.center = CGPointMake(WIDTH/2, HEIGHT/2);
    [view addSubview:imageView];
}

+ (void)hideProgressHudImageViewToView:(UIView *)view{
    if([view viewWithTag:1111]){
        [[view viewWithTag:1111] removeFromSuperview];
    }
}

@end