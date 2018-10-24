//
//  ActivityAndTopicOrFianaceCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/20.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityAndTopicOrFianaceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@property (weak, nonatomic) IBOutlet UIView *tagView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *readLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewLabel;
@property (weak, nonatomic) IBOutlet UIView *activityView;
@property (nonatomic ,strong) NSString *strTag;
- (void)tranferActivityAndTopicOrFianaceCellModel:(SearchModel *)model searchText:(NSString*)searchText searchType:(RSearchResult)searchType;
+ (CGFloat)backActivityAndTopicOrFianaceCellHeigth:(SearchModel *)model searchType:(RSearchResult)searchType;
@end
