//
//  NewLookHistoryCell.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/14.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewLookHistoryCell : UITableViewCell

- (void)updateDisplayModel:(LookHistoryModel*)model;

- (void)updateDisplayUserModel:(UserModel*)model;

@end
