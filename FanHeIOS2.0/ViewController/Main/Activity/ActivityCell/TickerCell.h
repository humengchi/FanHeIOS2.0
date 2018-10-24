//
//  TickerCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/10.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TickerCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (nonatomic ,assign) NSInteger index;
@property (nonatomic ,strong) NSMutableArray *array;
- (void)tranferTickerCellModel:(TicketModel *)model;
@end
