//
//  ActivityTalkCell.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/1/5.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityTalkCell : UITableViewCell

@property (nonatomic, strong) void(^selectedCell)(ActivityTalkCell *cellSelected);

+ (CGFloat)getCellHeight:(UserModel*)model;

- (void)updateDisplyCell:(UserModel*)model;

@end
