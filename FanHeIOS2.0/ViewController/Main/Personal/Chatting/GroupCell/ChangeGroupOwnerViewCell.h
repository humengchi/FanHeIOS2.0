//
//  ChangeGroupOwnerViewCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/8/29.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChangeGroupOwnerViewCellDelect <NSObject>

- (void)changeGroupOwer:(ChartModel *)model;
@end




@interface ChangeGroupOwnerViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (nonatomic, weak)id<ChangeGroupOwnerViewCellDelect>changeGroupOwnerViewCellDelect;
@property (nonatomic, strong) ChartModel *model;
- (void)tranferInterChartModelChangeOwer:(ChartModel *)model;
@end
