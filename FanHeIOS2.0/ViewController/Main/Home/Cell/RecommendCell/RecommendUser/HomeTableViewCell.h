//
//  ContactsCollectionView.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/10/25.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeTableViewCell : UITableViewCell

@property (nonatomic, strong) void(^deleteAllUserModel)();

- (void)updateDisplay:(HomeTableDataModel*)model;

@end
