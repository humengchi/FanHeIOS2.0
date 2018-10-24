//
//  RegisterGuideViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/7/28.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "RegisterGuideViewController.h"
#import "LoginViewController.h"
#import "RegisterNameViewController.h"

#import "AdminLoginViewController.h"

@interface RegisterGuideViewController ()

@property (nonatomic, weak) IBOutlet UILabel    *adminLoginLabel;

@end

@implementation RegisterGuideViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gotoAdminLogin:)];
    longPress.minimumPressDuration = 2;
    self.adminLoginLabel.userInteractionEnabled = YES;
    [self.adminLoginLabel addGestureRecognizer:longPress];
    // Do any additional setup after loading the view from its nib.
}

- (void)gotoAdminLogin:(UILongPressGestureRecognizer *)longPress{
     if(longPress.state == UIGestureRecognizerStateBegan) {
        AdminLoginViewController *vc = [CommonMethod getVCFromNib:[AdminLoginViewController class]];
        [self.navigationController pushViewController:vc animated:YES];
     }
}

#pragma mark - method
- (IBAction)loginButtonClicked:(UIButton *)sender {
    [self.navigationController pushViewController:[CommonMethod getVCFromNib:[LoginViewController class]] animated:YES];
}

- (IBAction)registerButtonClicked:(UIButton *)sender {[self.navigationController pushViewController:[CommonMethod getVCFromNib:[RegisterNameViewController class]] animated:YES];
}

@end
