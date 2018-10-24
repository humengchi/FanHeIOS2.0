//
//  TaskCell.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/8.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskCell : UITableViewCell

@property (nonatomic, strong) void(^taskButtonClicked)(TaskCell *cell);

- (void)updateDisplay:(TaskModel*)model;

@end
