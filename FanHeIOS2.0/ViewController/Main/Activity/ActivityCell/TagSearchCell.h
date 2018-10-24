//
//  TagSearchCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagSearchCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *guestnameLabel;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *addImageView;
@property (nonatomic ,strong) NSString *strTag;
- (void)tranferTagSearchCellModel:(MyActivityModel *)model;
+ (CGFloat)backTagSearchCellHeigth:(MyActivityModel *)model;

- (void)tranferTagSearchCellModelSearch:(SearchModel *)model;
+ (CGFloat)backTagSearchCellHeigthSearch:(SearchModel *)model;
@end
