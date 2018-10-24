//
//  SearchFriendTableViewCell.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/22.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchFriendTableViewCell : UITableViewCell

- (void)updateDisplaySearch:(SearchModel*)model showAddBtn:(BOOL)showAddBtn searchText:(NSString*)searchText;

- (void)updateDisplay:(ContactsModel*)model tdModel:(TopicDetailModel*)tdModel searchText:(NSString*)searchText hideAddBtn:(BOOL)hideAddBtn;

@end
