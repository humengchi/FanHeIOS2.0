//
//  ChangePhoneController.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/26.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ChangePhoneController.h"
#import "ChangeFillPhoneController.h"
@interface ChangePhoneController ()
@property (nonatomic ,strong) UITextField *passtextFile;
@end

@implementation ChangePhoneController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     self.view.backgroundColor = [UIColor colorWithHexString:@"EFEFF4"];
    NSString *phoneStr = [NSString stringWithFormat:@"您的手机号:%@",self.phoneStr];
    self.phoneLabel.attributedText = [self tranferStr:phoneStr];
    [self createCustomNavigationBar:@"更换手机号"];
}

- (IBAction)changePhoneBtnAction:(UIButton *)sender {
    ChangeFillPhoneController *phone = [[ChangeFillPhoneController alloc]init];
    phone.typeIndex = 1;
    [self.navigationController pushViewController:phone animated:YES];
}

- (NSMutableAttributedString *)tranferStr:(NSString *)str{
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:str];
    [AttributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"41464E"] range:NSMakeRange(6, self.phoneStr.length)];
    return AttributedStr;
}

@end
