//
//  MyGetCoffeeTableViewCell.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/26.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyGetCoffeeTableViewCell : UITableViewCell

- (void)updateDisplay:(MyGetCoffeeModel*)model isMyGetCoffee:(BOOL)isMyGetCoffee;

@end