//
//  AddFriendsCell.h
//  JinMai
//
//  Created by renhao on 16/5/20.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddFriendsCellDelegate <NSObject>

- (void)exchangeChatCard:(NSInteger)index;

@end

@interface AddFriendsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIImageView *levelImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lineLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cercityImageView;
@property (weak, nonatomic) IBOutlet UILabel *positiLabel;
@property (weak, nonatomic) IBOutlet UIButton *exchangeBtn;
@property (nonatomic,assign)  NSInteger index;
@property (nonatomic ,weak) id<AddFriendsCellDelegate>exchangeDelegate;
- (void)exchangeAddFriends:(ChartModel *)model;
+ (CGFloat)getCellHeight:(ChartModel*)model;

@end
