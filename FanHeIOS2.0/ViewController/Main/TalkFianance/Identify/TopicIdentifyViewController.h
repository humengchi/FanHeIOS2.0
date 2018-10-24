//
//  TopicIdentifyViewController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/17.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSUInteger, PublishType) {
    PublishType_Topic,
    PublishType_Viewpoint,
    PublishType_Review,
    PublishType_Activity,
    JoinType_Action,
    PublishType_Dynamic,
};

@interface TopicIdentifyViewController : BaseViewController

@property (nonatomic, assign) PublishType publishType;

@end
