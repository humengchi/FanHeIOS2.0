//
//  NewRecommendCell.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/2/24.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectedUser)(UserModel *Model);
typedef void(^RemoveUser)(UserModel *Model);

@interface NewRecommendCell : UICollectionViewCell

@property (nonatomic, strong) SelectedUser  selectedUser;
@property (nonatomic, strong) RemoveUser    removeUser;

- (void)updateDisplay:(UserModel*)model;

@end
