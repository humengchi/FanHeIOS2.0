//
//  MyActivityOrderCell.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/6/13.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyActivityOrderCell;

@protocol MyActivityOrderCellDelegate <NSObject>

- (void)myActivityOrderClickedFirstBtn:(MyActivityOrderCell*)cell model:(ActivityOrderModel*)model;

- (void)myActivityOrderClickedSecondBtn:(MyActivityOrderCell*)cell model:(ActivityOrderModel*)model;

@end

@interface MyActivityOrderCell : UITableViewCell

@property (nonatomic, weak) id<MyActivityOrderCellDelegate> delegate;

- (void)updateDisplay:(ActivityOrderModel*)model;

@end
