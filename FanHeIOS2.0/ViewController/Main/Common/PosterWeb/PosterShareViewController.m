//
//  PosterShareViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/2/21.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "PosterShareViewController.h"

@interface PosterShareViewController ()

@end

@implementation PosterShareViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ----------分享 ---
- (IBAction)firendClickWX:(UIButton*)sender{
    NSString *content = @"赶紧来领取我赠送的咖啡";
    NSString *title = @"我在泛合金融俱乐部挂出一杯咖啡";
    UIImage *imageSource = self.posterImage;
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    UMSocialPlatformType shareType;
    if (sender.tag == 200) {
        shareType = UMSocialPlatformType_WechatSession;
        [[AppDelegate shareInstance] setZhugeTrack:@"分享海报" properties:@{@"type":@"微信"}];
    }else if (sender.tag == 201) {
        shareType = UMSocialPlatformType_WechatTimeLine;
        [[AppDelegate shareInstance] setZhugeTrack:@"分享海报" properties:@{@"type":@"朋友圈"}];
    }
    UMShareImageObject *shareObject = [UMShareImageObject shareObjectWithTitle:title descr:content thumImage:imageSource];
    shareObject.shareImage = imageSource;
    messageObject.shareObject = shareObject;
    [[UMSocialManager defaultManager] shareToPlatform:shareType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
    }];
}

- (IBAction)backHomeButtonClicked:(id)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
