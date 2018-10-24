//
//  JinMaiSetController.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/24.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "JinMaiSetController.h"
#import "HelpView.h"
@interface JinMaiSetController ()<HelpViewDelegate>

@end

@implementation JinMaiSetController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar:@"聊天设置"];
    HelpView *helpView = [CommonMethod getViewFromNib:NSStringFromClass([HelpView class])];
    helpView.frame = CGRectMake(0, 64, WIDTH, HEIGHT - 64);
    helpView.backgroundColor = [UIColor colorWithHexString:@"EFEFF4"];
    helpView.helpDelegate = self;
    [self.view addSubview:helpView];
}

- (void)clearHistoryChart{
    [[[CommonUIAlert alloc] init] showCommonAlertView:self title:nil message:@"是否清空聊天记录" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
        
    } confirm:^{
        [self.conversation deleteAllMessages:nil];
        if ([self.setJinMaiDelegate respondsToSelector:@selector(referViewChat)]){
            [self.setJinMaiDelegate referViewChat];
        }
    }];
}

@end
