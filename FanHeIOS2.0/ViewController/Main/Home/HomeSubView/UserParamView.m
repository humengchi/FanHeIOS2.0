//
//  UserParamView.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/10/27.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "UserParamView.h"
#import "MyConnectionsController.h"
#import "VistorsListViewController.h"
#import "AttentionViewController.h"

@interface UserParamView ()

@property (nonatomic, weak) IBOutlet UILabel *recomdcntLabel;
@property (nonatomic, weak) IBOutlet UILabel *visitedcntLabel;
@property (nonatomic, weak) IBOutlet UILabel *attentedcntLabel;
@property (nonatomic, weak) IBOutlet UILabel *friendcntLabel;

@end

@implementation UserParamView

- (void)awakeFromNib{
    [super awakeFromNib];
    UserModel *model = [DataModelInstance shareInstance].userModel;
    self.recomdcntLabel.text = model.recomdcnt.stringValue;
    self.visitedcntLabel.text = model.visitedcnt.stringValue;
    self.attentedcntLabel.text = model.attentedcnt.stringValue;
    self.friendcntLabel.text = model.friendcnt.stringValue;
}

- (IBAction)gotoMyConnectionVC:(UIButton*)sender{
    if(self.userParamViewClicked){
        self.userParamViewClicked(sender.tag-200);
    }
    if(sender.tag == 201){
        VistorsListViewController *vc = [[VistorsListViewController alloc] init];
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }else if(sender.tag == 202){
        AttentionViewController *vc = [[AttentionViewController alloc] init];
        vc.typeIndex = 2;
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }else{
        MyConnectionsController *vc = [[MyConnectionsController alloc] init];
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }
}

@end
