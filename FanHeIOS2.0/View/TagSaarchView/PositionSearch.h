//
//  PositionSearch.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/16.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PositionSearchDelegate <NSObject>

- (void)gotoMakeSurePositionSearch:(NSString *)strPosition;
- (void)gotoAddressSearch:(NSInteger)index;
@end

@interface PositionSearch : UIView
@property (nonatomic, weak) id<PositionSearchDelegate>positionSearchDelegate;
- (void)createrTagSearchViewCity:(NSArray *)cityArray tag:(NSInteger)tag;
@end
