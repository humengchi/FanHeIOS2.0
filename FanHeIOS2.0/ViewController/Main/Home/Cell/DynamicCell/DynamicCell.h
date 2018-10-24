//
//  DynamicCell.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/2/28.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DynamicCell : UITableViewCell

@property (nonatomic, strong) DynamicModel *model;
- (id)initWithDataModel:(DynamicModel*)model identifier:(NSString*)identifier;

- (void)updateDisplayEnableEdit:(DynamicModel*)model;
- (void)updateDisplay:(DynamicModel*)model;

@property (nonatomic, strong) void(^refreshDynamicCell)(DynamicCell *cell);
@property (nonatomic, strong) void(^deleteDynamicCell)(DynamicCell *cell);
@property (nonatomic, strong) void(^deleteUserDynamic)(NSNumber *userId);
@property (nonatomic, strong) void(^attentUser)(BOOL isAttent);

@end
