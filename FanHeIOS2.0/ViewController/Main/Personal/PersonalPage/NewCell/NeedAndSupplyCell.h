//
//  NeedAndSupplyCell.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/14.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NeedAndSupplyCell : UITableViewCell

@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, assign) BOOL isNeed;

+ (CGFloat)getCellHeight:(NeedModel*)model;

- (void)updateDisplayModel:(NeedModel*)model;
@property (nonatomic, strong) void(^needOrSupplyChange)();

@end
