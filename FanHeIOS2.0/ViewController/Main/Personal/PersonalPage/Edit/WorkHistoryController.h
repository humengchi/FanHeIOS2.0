//
//  WorkHistoryController.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/2/8.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

@interface WorkHistoryController : BaseViewController
@property (nonatomic, assign) BOOL isMyPage;
@property (nonatomic, strong) NSNumber *isfriend;
@property (nonatomic, strong) workHistryModel *workModel;

@property (nonatomic, strong) void(^workHistoryDetailChange)(BOOL isEdit, workHistryModel *model);

@end
