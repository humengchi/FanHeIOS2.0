//
//  NeedSupplyErrorView.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/7/21.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface NeedSupplyErrorView : UIView

@property (nonatomic, copy) NSString *limit_times_cn;

@property (nonatomic, strong) void(^confirmButtonClicked)();

@property (nonatomic, weak) IBOutlet UILabel *showLabel;
@property (nonatomic, weak) IBOutlet UILabel *mainLabel;

@end
