//
//  JinMaiSetController.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/24.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JinMaiSetControllerDelegate <NSObject>

- (void)referViewChat;

@end
@interface JinMaiSetController : BaseViewController
@property (strong, nonatomic) EMConversation *conversation;
@property (nonatomic ,weak) id<JinMaiSetControllerDelegate>setJinMaiDelegate;
@end
