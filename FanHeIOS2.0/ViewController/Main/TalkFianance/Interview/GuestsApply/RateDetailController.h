//
//  RateDetailController.h
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/19.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface RateDetailController : BaseViewController
@property (nonatomic,strong) NSNumber* reviewid;
@property (nonatomic ,strong) NSString *shareImage;
@property (nonatomic ,strong) NSString *shareTitle;
@property (nonatomic ,strong) NSString *shareUrl;
@property (nonatomic ,strong) NSString *shareCount;
@end
