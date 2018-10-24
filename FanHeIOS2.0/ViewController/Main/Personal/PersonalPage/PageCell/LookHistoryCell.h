//
//  LookHistoryCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/10/28.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface LookHistoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic ,assign) BOOL isMyPage;
@property (weak, nonatomic) IBOutlet UIImageView *subjectImageView;
@property (weak, nonatomic) IBOutlet UIImageView *viteryImageView;
@property (weak, nonatomic) IBOutlet UIImageView *resignImageView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *onlyNameLabel;
@property (nonatomic ,assign) BOOL isApply;
- (void)lookHistoryModel:(LookHistoryModel *)model;

@end
