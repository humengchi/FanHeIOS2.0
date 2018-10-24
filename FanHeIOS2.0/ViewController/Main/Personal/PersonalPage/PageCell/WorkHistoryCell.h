//
//  WorkHistoryCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/10/28.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WorkHistoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *tagCell;
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (nonatomic,assign)  NSInteger Index;
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *workDetailLabel;

@property (nonatomic,assign)BOOL isMainHistory;
- (void)workHistoryCellModel:(workHistryModel *)model;
+ (CGFloat)workHistoryCellModel:(workHistryModel*)model;
@end
