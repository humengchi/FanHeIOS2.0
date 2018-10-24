//
//  AccountViewController.m
//  JinMai
//
//  Created by renhao on 16/5/10.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import "AccountViewController.h"
#import "ChangePhoneController.h"
#import "ChangeFillPhoneController.h"

@interface AccountViewController ()
@property (nonatomic, strong) NSMutableArray        *dataArray;
@property (nonatomic,strong)UILabel *numberLabel;
@property (nonatomic,strong) NSString *uid;
@property (nonatomic,strong) NSString *phoneNumber;
@end

@implementation AccountViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"EFEFF4"];
     [self createCustomNavigationBar:@"账户安全"];
   self.phoneLabel.text = [DataModelInstance shareInstance].userModel.phone;
    
}
- (IBAction)changePhoneTap:(UITapGestureRecognizer *)sender {
    ChangePhoneController *phone = [[ChangePhoneController alloc]init];
    phone.phoneStr = self.phoneLabel.text;
    [self.navigationController pushViewController:phone animated:YES];
    
}
- (IBAction)changePassTap:(UITapGestureRecognizer *)sender {
    ChangeFillPhoneController *phone = [[ChangeFillPhoneController alloc]init];
    phone.typeIndex = 2;
    [self.navigationController pushViewController:phone animated:YES];
}

#pragma mark ----------//相关请求
- (void)referNotView:(NSNotification *)text{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.textLabel.text = @"已绑定手机号";
    self.numberLabel.text = text.userInfo[@"textOne"];
    self.dataArray = [NSMutableArray arrayWithObjects:@[@"已绑定手机号"], @[@"修改密码"], nil];
}

@end
