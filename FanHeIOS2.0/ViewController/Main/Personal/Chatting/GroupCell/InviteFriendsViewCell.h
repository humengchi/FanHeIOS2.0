//
//  InviteFriendsViewCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/8/18.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol InviteFriendsViewCellDelect <NSObject>

- (void)delectGroupFriends:(NSIndexPath *)indeth;
@end


@interface InviteFriendsViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sideLAbel;
@property (weak, nonatomic) IBOutlet UIButton *delectBtn;
@property (assign, nonatomic) BOOL isOwer;
@property (strong, nonatomic) NSIndexPath *indexPath;
- (void)tranferInterChartModel:(ChartModel *)model;
@property (nonatomic, weak)id<InviteFriendsViewCellDelect>inviteFriendsViewCellDelect;
@end
