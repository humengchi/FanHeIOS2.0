//
//  CardListCell.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/16.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardListCell : UITableViewCell

- (void)updateDisplay:(CardScanModel*)model;
- (void)updateDisplayIsChatRoom:(CardScanModel*)model;

@end
