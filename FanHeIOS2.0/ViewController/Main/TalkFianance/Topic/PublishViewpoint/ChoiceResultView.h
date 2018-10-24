//
//  ChoiceResultView.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/3/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChoiceResultView : UIView

@property (nonatomic, strong) void(^ChoiceResultViewType)(NSInteger tag);

@end
