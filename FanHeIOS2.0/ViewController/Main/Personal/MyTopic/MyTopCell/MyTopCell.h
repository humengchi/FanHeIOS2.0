//
//  MyTopCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/20.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTopCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *pointLabel;
@property (weak, nonatomic) IBOutlet UILabel *attionLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewPointLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
- (void)tranferMyTopicModel:(MyTopicModel *)model;
@end
