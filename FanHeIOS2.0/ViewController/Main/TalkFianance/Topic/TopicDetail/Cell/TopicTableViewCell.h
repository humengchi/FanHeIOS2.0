//
//  TopicTableViewCell.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/15.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopicTableViewCell : UITableViewCell

- (void)updateDisplay:(ViewpointModel*)model;

@property (nonatomic, strong) void(^selectCell)(UITapGestureRecognizer *tap);

@end
