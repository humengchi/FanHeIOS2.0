//
//  CreateTopicTagsViewController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/19.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

@interface CreateTopicTagsViewController : BaseViewController

@property (nonatomic, strong) TopicDetailModel *tdModel;

@property (nonatomic, assign) BOOL isActivity;//发布活动
@property (nonatomic, strong) NSArray *actSelectedArray;
@property (nonatomic, strong) void(^activitySeletedTags)(NSString *tags);

@end
