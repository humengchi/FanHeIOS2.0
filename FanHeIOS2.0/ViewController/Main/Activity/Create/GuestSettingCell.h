//
//  GuestSettingCell.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/1/3.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuestSettingCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lineLabel;

@property (nonatomic, strong) void(^guestParamEdit)(NSMutableDictionary *dict, GuestSettingCell *changeCell);
@property (nonatomic, strong) void(^deleteGuest)(GuestSettingCell *cell);

- (void)updateDisply:(NSMutableDictionary*)dict;

@end
