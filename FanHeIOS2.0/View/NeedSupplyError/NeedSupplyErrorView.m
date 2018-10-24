//
//  NeedSupplyErrorView.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/7/21.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "NeedSupplyErrorView.h"
#import "TaskListViewController.h"

@interface NeedSupplyErrorView ()

@property (nonatomic, weak) IBOutlet UIButton *cancleBtn;
@property (nonatomic, weak) IBOutlet UIButton *okBtn;

@end

@implementation NeedSupplyErrorView

- (IBAction)clearViewFormeSupper:(UIButton*)sender {
    if(sender.tag == 202){
        if([CommonMethod paramNumberIsNull:[DataModelInstance shareInstance].coffeeBeans].integerValue<3){
            TaskListViewController *vc = [[TaskListViewController alloc] init];
            [[self viewController].navigationController pushViewController:vc animated:YES];
            [self removeFromSuperview];
        }else{
            if(self.confirmButtonClicked){
                self.confirmButtonClicked();
            }
            [self removeFromSuperview];
        }
    }else{
        [self removeFromSuperview];
    }
}

- (void)setLimit_times_cn:(NSString *)limit_times_cn{
    if([CommonMethod paramNumberIsNull:[DataModelInstance shareInstance].coffeeBeans].integerValue<3){
        self.showLabel.text = @"做日常任务赢咖啡豆，增加供需条数！";
        [self.cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
        [self.okBtn setTitle:@"做任务" forState:UIControlStateNormal];
    }else{
        self.showLabel.text = @"再次发布将消耗三个咖啡豆，是否继续？";
        [self.cancleBtn setTitle:@"否" forState:UIControlStateNormal];
        [self.okBtn setTitle:@"是" forState:UIControlStateNormal];
    }
}

@end
