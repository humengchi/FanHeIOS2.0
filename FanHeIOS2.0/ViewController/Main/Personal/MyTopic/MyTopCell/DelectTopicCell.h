//
//  DelectTopicCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/21.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DelectTopicCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLAbel;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *deleView;
@property (weak, nonatomic) IBOutlet UIView *DeleCoveView;
@property (strong, nonatomic)MyTopicModel * topModel;
- (void)tranferDelectTopicCellMyTopicModel:(MyTopicModel *)model uiseID:(NSNumber *)uid;
+ (CGFloat)backDelectTopicCellHeigthMyTopicModel:(MyTopicModel *)model;
@end
