//
//  FriendTableViewCell.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/18.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendTableViewCell : UITableViewCell

- (void)updateDisplay:(ChartModel*)model;
- (void)updateDisplayOnlyName:(ChartModel*)model;

- (void)updateDisplyGetCoffee:(MyGetCoffeeModel*)model;

- (void)updateDisplayGroup:(EMGroup *)group;

@end
