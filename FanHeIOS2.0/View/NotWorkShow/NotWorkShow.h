//
//  NotWorkShow.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/9/6.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AgainGetData)();

@interface NotWorkShow : UIView

@property (nonatomic, strong) AgainGetData againGetData;
@end
