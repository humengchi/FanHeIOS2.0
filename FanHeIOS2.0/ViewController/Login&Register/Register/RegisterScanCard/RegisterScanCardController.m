//
//  RegisterScanCardController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/11.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "RegisterScanCardController.h"
#import "NewRecommendController.h"
#import "ScanCameraController.h"

@interface RegisterScanCardController ()

@end

@implementation RegisterScanCardController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kTableViewBgColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)gotoRecommendButtonClicked:(id)sender{
    [[AppDelegate shareInstance] gotoRecommendContacts];
}

- (IBAction)scanButtonClicked:(id)sender{
    ScanCameraController *vc = [CommonMethod getVCFromNib:[ScanCameraController class]];
    vc.isMyCard = YES;
    vc.isRegister = YES;
    [self.navigationController pushViewController:vc animated:YES];
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
