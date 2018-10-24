//
//  ActivityLocationViewController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/1/3.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

@interface ActivityLocationViewController : BaseViewController

@property (nonatomic, strong) void(^selectLoaction)(AMapPOI *model);

@end
