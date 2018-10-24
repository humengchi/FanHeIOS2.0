//
//  DymanicRateController.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/3/2.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"
@protocol DymanicRateControllerDelegate <NSObject>
@optional

- (void)succendRateDynamic;

- (void)successDynamicCommentModel:(DynamicCommentModel*)model;

@end
@interface DymanicRateController : BaseViewController
@property (nonatomic,strong) NSNumber *dynamicID;
@property (nonatomic, strong) DynamicModel *dynamicModel;
@property (nonatomic,assign) BOOL fristRate;
@property (nonatomic,strong) NSString *nameStr;
@property (nonatomic,weak) id<DymanicRateControllerDelegate>dymanicRateControllerDelegate;
@end
