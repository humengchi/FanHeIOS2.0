//
//  MessageSidViewController.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/8/7.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "EaseMessageViewController.h"

@interface MessageSidViewController : EaseMessageViewController<EaseMessageViewControllerDelegate, EaseMessageViewControllerDataSource>
@property (nonatomic ,assign) BOOL isMakeGroup;
@property (nonatomic ,assign)  BOOL isBack;
@property (nonatomic ,strong) NSString *titleStr;
- (void)showMenuViewController:(UIView *)showInView
                  andIndexPath:(NSIndexPath *)indexPath
                   messageType:(EMMessageBodyType)messageType;


@end
