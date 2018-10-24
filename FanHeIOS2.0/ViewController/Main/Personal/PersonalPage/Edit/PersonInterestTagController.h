//
//  PersonInterestTagController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/20.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

@interface PersonInterestTagController : BaseViewController

@property (nonatomic, strong) NSMutableArray    *dataArray;
@property (nonatomic, assign) BOOL isSelfTag;
@property (nonatomic, strong) void(^saveTagSuccess)(NSMutableArray *array);

@end
