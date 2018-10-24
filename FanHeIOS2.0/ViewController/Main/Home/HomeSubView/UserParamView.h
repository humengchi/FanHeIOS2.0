//
//  UserParamView.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/10/27.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UserParamViewClicked)(NSInteger index);

@interface UserParamView : UIView

@property (nonatomic, strong) UserParamViewClicked userParamViewClicked;

@end
