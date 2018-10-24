//
//  AdminGetCoffeeResultViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/9/6.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "AdminGetCoffeeResultViewController.h"

@interface AdminGetCoffeeResultViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *iconImageView;
@property (nonatomic, weak) IBOutlet UILabel *statueLabel;

@end

@implementation AdminGetCoffeeResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kBackgroundColorDefault;
    if(self.resultType == Result_Type_GetCoffee){
        self.iconImageView.image = kImageWithName(@"icon_gly_dhcg");
        self.statueLabel.text = @"兑换成功!";
    }else if(self.resultType == Result_Type_HangCoffee){
        self.iconImageView.image = kImageWithName(@"icon_gly_dhcg");
        self.statueLabel.text = @"挂出成功!";
    }else{
        self.iconImageView.image = kImageWithName(@"icon_gly_hscg");
        self.statueLabel.text = @"回收成功!";
    }
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - method
- (IBAction)navBackButtonClicked:(id)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)startReadZbarButtonClicked:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"satrtReadButtonClicked" object:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
