//
//  GooAtCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/10/28.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaMessageModel.h"
@protocol GooAtCellDelegate <NSObject>
//
- (void)searchResultGoodAt:(NSInteger)index;


@end
@interface GooAtCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIScrollView *goodAtScrollView;
@property (nonatomic ,weak) id<GooAtCellDelegate>gooAtCellDelegate;
- (void)tranferGoodAt:(TaMessageModel *)model;
@end
