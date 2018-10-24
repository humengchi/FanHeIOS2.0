//
//  PushTopicCell.h
//  FanHeIOS2.0
//
//  Created by JackieWang on 15/12/2016.
//  Copyright © 2016 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PushTopicCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@property (weak, nonatomic) IBOutlet UIImageView *coverImangeView;
@property (weak, nonatomic) IBOutlet UILabel *attionCountlabel;
@property (weak, nonatomic) IBOutlet UILabel *viewpointLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
- (void)tranferPushTopicModel:(FinanaceModel *)model;
@end
