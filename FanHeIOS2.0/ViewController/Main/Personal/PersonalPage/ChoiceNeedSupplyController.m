//
//  ChoiceNeedSupplyController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/19.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ChoiceNeedSupplyController.h"
#import "PublishNeedSupplyController.h"

@interface ChoiceNeedSupplyController ()

@property (nonatomic, weak) IBOutlet UILabel *showLabel;

@end

@implementation ChoiceNeedSupplyController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.showLabel.text = [NSString stringWithFormat:@"每天只能发布%@条", self.limit_times_cn];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar:@"选择供需"];
    self.view.backgroundColor = kTableViewBgColor;
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)choiceButtonClicked:(UIButton*)sender{
    PublishNeedSupplyController *vc = [CommonMethod getVCFromNib:[PublishNeedSupplyController class]];
    vc.isNeed = sender.tag==201;
    vc.publishNeedSupplySuccess = ^(BOOL isNeed) {
        if(self.publishNeedSupplySuccess){
            self.publishNeedSupplySuccess(isNeed);
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

@end
