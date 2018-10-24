//
//  NODataTableViewCell.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NODataTableViewCell : UITableViewCell

@property (nonatomic, strong) void (^clickButton)();

@property (nonatomic, weak) IBOutlet UILabel    *mainLabel;
@property (nonatomic, weak) IBOutlet UILabel    *subLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIButton *btnImageView;

@end
