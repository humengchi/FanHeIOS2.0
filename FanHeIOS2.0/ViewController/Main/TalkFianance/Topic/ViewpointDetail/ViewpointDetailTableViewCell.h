//
//  ViewpointDetailTableViewCell.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/15.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewpointDetailTableViewCell;

typedef void(^ReplyReviewSuccess)();
typedef void(^DeleteReviewSuccess)(ViewpointDetailTableViewCell *cell);

@interface ViewpointDetailTableViewCell : UITableViewCell

@property (nonatomic, strong) ReplyReviewSuccess replyReviewSuccess;

@property (nonatomic, strong) DeleteReviewSuccess deleteReviewSuccess;

- (void)updateDisplay:(ReviewModel*)model vpdModel:(ViewpointDetailModel*)vpdModel;

@end
