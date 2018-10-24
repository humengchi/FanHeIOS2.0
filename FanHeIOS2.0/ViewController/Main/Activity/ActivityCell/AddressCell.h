//
//  AddressCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/5.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddressCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *addressImageView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
- (void)tranferAddressCellModel:(MyActivityModel *)model;
+ (CGFloat)backAddressCellHeigth:(MyActivityModel *)model;
@end
