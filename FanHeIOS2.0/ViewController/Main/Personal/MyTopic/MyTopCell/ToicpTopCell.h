//
//  ToicpTopCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/20.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToicpTopCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *acountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
- (void)createrToicpTopCell:(NSInteger)index;
@end
