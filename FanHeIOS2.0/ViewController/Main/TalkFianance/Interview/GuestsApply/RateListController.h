//
//  RateListController.h
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

@interface RateListController : BaseViewController
@property (nonatomic,strong) NSNumber* postID;
@property (nonatomic ,strong) NSString *shareImage;
@property (nonatomic ,strong) NSString *shareTitle;
@property (nonatomic ,strong) NSString *shareUrl;
@property (nonatomic ,strong) NSString *shareCount;

@property (nonatomic ,strong) NSString *activityTitle;
@property (nonatomic ,strong) NSString *tag;
@end
