//
//  WorkHistoryEditorViewController.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/10/26.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol WorkHistoryEditorViewControllerDelegate <NSObject>

- (void)changeWorkHistory:(workHistryModel *)model delect:(BOOL)isdelect;

@end

@interface WorkHistoryEditorViewController : BaseViewController

@property (nonatomic,strong) workHistryModel *workModel;

@property (nonatomic,assign)  NSInteger index; //1.只有保存 2.删除和保存

@property (nonatomic,weak) id<WorkHistoryEditorViewControllerDelegate>workDelegate;

@end
