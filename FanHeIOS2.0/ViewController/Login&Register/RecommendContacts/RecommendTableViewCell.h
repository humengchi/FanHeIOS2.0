//
//  RecommendTableViewCell.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/10/25.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectedUser)(NSArray *array);
typedef void(^RemoveUser)(NSArray *array);

@interface RecommendTableViewCell : UITableViewCell

@property (nonatomic, strong) SelectedUser  selectedUser;
@property (nonatomic, strong) RemoveUser    removeUser;

- (void)updateDisplay:(RecommendModel*)model;

@end
