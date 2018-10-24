//
//  HeaderView.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/3/1.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeaderView : UIView

- (void)updateDisplay:(DynamicModel *)dynamicModel;

@property (nonatomic, weak) IBOutlet UIButton *choiceBtn;

@property (nonatomic, strong) void(^deleteDynamic)();

@property (nonatomic, strong) void(^ignoreDynamic)();

@property (nonatomic, strong) void(^deleteUserDynamic)(NSNumber *userId);

@property (nonatomic, strong) DynamicModel *model;

@end
