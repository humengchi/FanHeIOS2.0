//
//  ApplySettingCell.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/1/3.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ApplySettingCell : UITableViewCell


@property (nonatomic, strong) void(^ticketParamEdit)(NSMutableDictionary *dict, ApplySettingCell *delCell);
@property (nonatomic, strong) void(^deleteTicket)(ApplySettingCell *cell);

- (void)updateDisply:(NSMutableDictionary*)dict;

@end
