//
//  ShowQRCodeViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/22.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ShowQRCodeViewController.h"
#import "CRNavigationBar.h"
#import "QRCodeGenerator.h"

@interface ShowQRCodeViewController ()

@property (nonatomic, weak) IBOutlet UILabel *codeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *codeImageView;
@end

@implementation ShowQRCodeViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = HEX_COLOR(@"EFEFF4");
    self.codeLabel.text = [NSString stringWithFormat:@"咖啡编号：%@", self.codeStr];
    [self createCustomNavigationBar:@"二维码"];
    
    
    self.codeImageView.image = [QRCodeGenerator qrImageForString:[NSString stringWithFormat:@"%@%@", CoffeeQRCodeURL, self.coffeeId] imageSize:self.codeImageView.bounds.size.width];
    // Do any additional setup after loading the view from its nib.
}

@end
