//
//  TalkFinanceCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/15.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TalkFinanceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *coverImageVIew;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *readCountLabel;

+ (CGFloat)tableFrameTalkFinanceCellHeigthContactsModel:(FinanaceModel *)fianaceModel;
- (void)tranferFianaceModel:(FinanaceModel *)fianaceModel;

@end
