//
//  CardGroupViewController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/16.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

@interface CardGroupViewController : BaseViewController

@property (nonatomic, assign) BOOL isShowGroupList;//是否是展示分组，不是添加分组

@property (nonatomic, strong) CardScanModel *model;

@end
