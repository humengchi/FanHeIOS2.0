//
//  ShowPersonalQRCodeViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/22.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ShowPersonalQRCodeViewController.h"
#import "CRNavigationBar.h"
#import "QRCodeGenerator.h"

@interface ShowPersonalQRCodeViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *codeImageView;
@property (nonatomic, weak) IBOutlet UIImageView *headerImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;
@end

@implementation ShowPersonalQRCodeViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = HEX_COLOR(@"EFEFF4");
    [self createCustomNavigationBar:@"我的二维码"];
    
    [CALayer updateControlLayer:self.headerImageView.layer radius:21 borderWidth:0 borderColor:nil];
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:[DataModelInstance shareInstance].userModel.image] placeholderImage:KHeadImageDefaultName([DataModelInstance shareInstance].userModel.realname)];
    
    self.nameLabel.text = [DataModelInstance shareInstance].userModel.realname;
    self.detailLabel.text = [NSString stringWithFormat:@"%@%@", [CommonMethod paramStringIsNull:[DataModelInstance shareInstance].userModel.company], [CommonMethod paramStringIsNull:[DataModelInstance shareInstance].userModel.position]];
    if(self.detailLabel.text.length == 0){
        self.detailLabel.text = @"公司职位";
    }
    self.codeImageView.image = [QRCodeGenerator qrImageForString:[NSString stringWithFormat:@"%@%@",ShareHomePageURL, [DataModelInstance shareInstance].userModel.userId] imageSize:self.codeImageView.bounds.size.width];
    // Do any additional setup after loading the view from its nib.
}

@end
