//
//  NewWorkHistoryCell.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/14.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewWorkHistoryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lineLabel;

+ (CGFloat)getCellHeight:(workHistryModel*)model;

- (void)updateDisplayModel:(workHistryModel*)model;

@end
