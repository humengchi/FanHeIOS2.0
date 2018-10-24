//
//  ActivityApplyCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/3.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityApplyCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *applyManLabel;
- (void)traferActivityApplyCellModel:(MyActivityModel *)model array:(NSMutableArray *)applyArray;
@end
