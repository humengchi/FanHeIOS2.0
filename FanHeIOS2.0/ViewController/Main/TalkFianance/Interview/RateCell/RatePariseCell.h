//
//  RatePariseCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/19.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RatePariseCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *memberImageView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *viteryImageView;
@property (weak, nonatomic) IBOutlet UIImageView *interViewImageView;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
- (void)createrRateModel;
@end
