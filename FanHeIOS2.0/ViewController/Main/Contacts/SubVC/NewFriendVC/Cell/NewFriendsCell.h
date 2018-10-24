//
//  NewFriendsCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/29.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewFriendsCellDelegate <NSObject>

- (void)sendAddFriends:(NSInteger)index;

@end


@interface NewFriendsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *messageTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *attionBtn;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageVIew;
@property (weak, nonatomic) IBOutlet UIImageView *rzImageView;
@property (weak, nonatomic) IBOutlet UIImageView *vipImageView;
@property (nonatomic ,assign) NSInteger index;
@property (nonatomic ,weak) id<NewFriendsCellDelegate>friendsDelegate;
- (void)sendGoodFriends:(ChartModel *)model;
@end
