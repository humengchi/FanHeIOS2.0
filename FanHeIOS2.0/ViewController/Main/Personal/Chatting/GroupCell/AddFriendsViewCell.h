//
//  AddFriendsViewCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/8/11.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddFriendsViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (assign, nonatomic) BOOL isRemove;
- (void)tranferChartModel:(ChartModel *)model groupMembers:(NSArray *)memberArray addFriends:(NSMutableArray *)addFriends;
@end
