//
//  ChoseActivityViewController.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/5/10.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

@interface ChoseActivityViewController : BaseViewController
@property (nonatomic, strong) void(^activitySeletedTagsStr)(NSString *tags);
@property (nonatomic, strong) NSArray *actSelectedTagArray;
@end
