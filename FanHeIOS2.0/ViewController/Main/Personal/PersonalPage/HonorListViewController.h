//
//  HonorListViewController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/19.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

@interface HonorListViewController : BaseViewController

@property (nonatomic, strong) NSMutableArray *honorArray;

@property (nonatomic, strong) void(^honorListChange)(NSMutableArray *honorArray);

@end
