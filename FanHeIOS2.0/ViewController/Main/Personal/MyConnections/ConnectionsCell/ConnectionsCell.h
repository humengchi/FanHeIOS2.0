//
//  ConnectionsCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/29.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConnectionsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headerImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *leftImage;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;

- (void)updateDisplay:(NSInteger)row num:(NSNumber*)num;

@end
