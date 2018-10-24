//
//  SaveCardSuccessController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/14.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "SaveCardSuccessController.h"
#import "CardGroupViewController.h"
#import "CardDetailViewController.h"

@interface SaveCardSuccessController ()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

@end

@implementation SaveCardSuccessController

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar:@"名片已保存"];
    self.nameLabel.text = [NSString stringWithFormat:@"%@的名片", self.model.name];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - method
- (void)customNavBackButtonClicked{
    NSArray *vcs = self.navigationController.viewControllers;
    UIViewController *vc = vcs[vcs.count-5];
    [self.navigationController popToViewController:vc animated:YES];
}

- (IBAction)scanAgainButtonClicked:(id)sender{
    NSArray *vcs = self.navigationController.viewControllers;
    UIViewController *vc = vcs[vcs.count-4];
    [self.navigationController popToViewController:vc animated:YES];
}

- (IBAction)groupButtonClicked:(id)sender{
    NSArray *vcs = self.navigationController.viewControllers;
    NSMutableArray *vcsNew = [NSMutableArray array];
    for(int i=0; i<=vcs.count-5; i++){
        [vcsNew addObject:vcs[i]];
    }
    CardGroupViewController *cardGroupVC = [CommonMethod getVCFromNib:[CardGroupViewController class]];
    cardGroupVC.isShowGroupList = NO;
    cardGroupVC.model = self.model;
    [vcsNew addObject:cardGroupVC];
    [self.navigationController setViewControllers:vcsNew animated:YES];
}

- (IBAction)cardDetailButtonClicked:(id)sender{
    NSArray *vcs = self.navigationController.viewControllers;
    NSMutableArray *vcsNew = [NSMutableArray array];
    for(int i=0; i<=vcs.count-5; i++){
        [vcsNew addObject:vcs[i]];
    }
    CardDetailViewController *cardListVC = [CommonMethod getVCFromNib:[CardDetailViewController class]];
    cardListVC.cardId = self.model.cardId;
    [vcsNew addObject:cardListVC];
    [self.navigationController setViewControllers:vcsNew animated:YES];
}

@end
