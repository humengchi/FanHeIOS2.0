//
//  GoodAtViewController.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/11/3.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//
//资讯类型posts
typedef NS_ENUM(NSInteger, BUNESS_JOBTYPE) {
    BUNESS_ALL_JOBTYPE = 0,
    BUNESS_HOT_JOBTYPE,
    BUNESS_SEARCH_JOBTYPE,
};
#import "BaseViewController.h"

@protocol GoodAtViewControllerDelegate <NSObject>

- (void)referViewGoodAtJob;

@end

@interface GoodAtViewController : BaseViewController

@property (nonatomic,strong) NSArray *array;
@property (nonatomic, assign) BUNESS_JOBTYPE  jobShoweType;
@property (nonatomic,weak)id<GoodAtViewControllerDelegate>gooJobDelegate;

@property (nonatomic, strong) void(^needSupplyTagsSuccess)(NSMutableArray *tagsArray);
@end
