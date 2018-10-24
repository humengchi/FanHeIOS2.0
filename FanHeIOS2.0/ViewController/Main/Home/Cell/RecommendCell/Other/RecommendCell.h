//
//  RecommendCell.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/2/28.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RecommendType) {
    RecommendType_Topic = 14,
    RecommendType_Activity = 15,
    RecommendType_Post = 16,
    RecommendType_FriendAddFriend = 18,
    RecommendType_MayInterestIndustry = 19,
};

@interface RecommendCell : UITableViewCell

- (void)updateDisplay:(HomeRCMModel*)model;

- (void)updateDisplayMayInterestIndustry:(HomeRCMModel*)model;

- (void)updateDisplayFAF:(HomeRCMModel*)model;


@property (nonatomic, strong) void(^deleteRecommendCell)(RecommendCell *cell);

@end
