//
//  ChattingListCell.h
//  JinMai
//
//  Created by renhao on 16/5/18.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ChattingListCell : UITableViewCell
@property (nonatomic, strong) NSAttributedString *str;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *detailMsg;
@property (nonatomic, strong) NSString *time;
@property (nonatomic ,assign) NSInteger unreadCount;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger hasVaildUse;

- (void)traderCharttingMessageGroup:(EMGroup*)group;
- (void)traderCharttingMessageGroupSpace:(NSString*)groupId;

- (void)traderCharttingMessage;
@end
