//
//  TitleViewCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/3.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  TitleViewCellDelegate <NSObject>

- (void)viewIsHidder;

@end

@interface TitleViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet UILabel *lookLabel;
@property (weak, nonatomic) IBOutlet UIImageView *lookImageView;
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@property (weak ,nonatomic) id<TitleViewCellDelegate>titleViewCellDelegate;
@property (nonatomic ,strong) MyActivityModel *model;
- (void)tranferTitleViewCellModel:(MyActivityModel *)model;
+ (CGFloat)backTitleViewCellHeigth:(MyActivityModel *)model;
@end
