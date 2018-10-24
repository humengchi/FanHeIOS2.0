//
//  ToicpCharacterCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/20.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToicpCharacterCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *attionLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewPointLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
- (void)tranferToicpCharacterCellMyTopicModel:(MyTopicModel *)model;
+ (CGFloat)backToicpCharacterCell:(MyTopicModel *)model;
@end
