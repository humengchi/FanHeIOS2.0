//
//  ViewpointDetailViewController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/15.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^DeleteViewpointDetail)();
typedef void(^PraiseSuccess)();
typedef void(^PublishReview)();

@interface ViewpointDetailViewController : BaseViewController

@property (nonatomic, strong) NSNumber *viewpointId;

@property (nonatomic, strong) DeleteViewpointDetail deleteViewpointDetail;
@property (nonatomic, strong) PraiseSuccess praiseSuccess;
@property (nonatomic, strong) PublishReview publishReview;

@property (nonatomic, strong) TopicDetailModel *topicDetailModel;

@end
