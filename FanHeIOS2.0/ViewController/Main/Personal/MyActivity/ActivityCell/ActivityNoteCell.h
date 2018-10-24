//
//  ActivityNoteCell.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/1/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityNoteCell : UITableViewCell

- (void)updateDisplyCell:(ActivityNoteModel*)model;

+ (CGFloat)getCellHeight:(ActivityNoteModel*)model;

@end
