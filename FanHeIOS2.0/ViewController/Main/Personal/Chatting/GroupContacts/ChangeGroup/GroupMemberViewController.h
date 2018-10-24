//
//  GroupMemberViewController.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/8/23.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"



@protocol GroupMemberViewControllerDelegate;





@interface GroupMemberViewController : BaseViewController
{
    __weak id<GroupMemberViewControllerDelegate> _delegate;
    NSMutableArray *_dataSource;
}

@property (nonatomic ,strong) NSString *groupID;
@property (nonatomic ,weak)id<GroupMemberViewControllerDelegate>groupMemberViewControllerDelegate;


@end

@protocol GroupMemberViewControllerDelegate <NSObject>
/**
 *  选择完成之后代理方法
 *
 *  @param viewController  列表视图
 *  @param selectedSources 选择的联系人信息，每个联系人提供姓名和手机号两个字段，以字典形式返回
 *  @return 是否隐藏页面
 */
- (void)viewController:(GroupMemberViewController *)viewController didFinishSelectedSources:(ChartModel *)model;

/**
 *  页面返回
 *
 *  @param viewController  列表视图
 */
- (void)viewControllerDidSelectBack:(GroupMemberViewController *)viewController;


@end
