//
//  ConventionTopicCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/15.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConventionTopicCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *memberImageView;
@property (weak, nonatomic) IBOutlet UILabel *attentionLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewpiontLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UITextView *sidTextView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic ,strong) FinanaceModel *fianaceModel;
- (void)createrConventionTip:(FinanaceModel *)model;
+ (CGFloat)tableFrameBackCellHeigthContactsModel:(FinanaceModel *)finceModel;
@end
