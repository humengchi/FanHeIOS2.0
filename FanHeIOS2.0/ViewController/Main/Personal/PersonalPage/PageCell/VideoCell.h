//
//  VideoCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/4.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaMessageModel.h"

@protocol VideoCellDelegate <NSObject>

- (void)eaditMyInduceAction;
@end


@interface VideoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *eaditMyInduceBtn;

@property (weak, nonatomic) IBOutlet UILabel *siderLabel;
@property (nonatomic,weak)id<VideoCellDelegate>videoDelegate;

- (void)tranferVideoTaMessageModel:(TaMessageModel *)model workArray:(NSMutableArray *)array;
+ (CGFloat)videoHeigthTaMessageModel:(TaMessageModel*)model;
@end
