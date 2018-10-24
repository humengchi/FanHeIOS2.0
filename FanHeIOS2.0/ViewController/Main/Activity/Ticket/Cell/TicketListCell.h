//
//  TicketListCell.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/6/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TicketListCell : UITableViewCell

- (void)updateDisplay:(TicketModel*)model isSelected:(BOOL)isSelected;
+ (CGFloat)getCellHeight:(TicketModel*)model;

@end
