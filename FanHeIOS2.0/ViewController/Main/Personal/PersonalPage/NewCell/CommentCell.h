//
//  CommentCell.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/14.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentCell : UITableViewCell

+ (CGFloat)getCellHeight:(UserModel*)model;

- (void)updateDisplayModel:(UserModel*)model isMyHomePage:(BOOL)isMyHomePage;

@property (nonatomic, strong) void(^deleteComment)(CommentCell* cell);

@end