//
//  InviteAnswerViewController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/15.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

@interface InviteAnswerViewController : BaseViewController

@property (nonatomic, strong) TopicDetailModel *tdModel;
@property (nonatomic, assign) BOOL isAt;//是否是@ta

@property (nonatomic, assign) BOOL isCreateTopic;//发起话题成功之后，邀请

@end
