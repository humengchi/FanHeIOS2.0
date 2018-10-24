//
//  TagSearchView.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TagSearchViewDelegate <NSObject>


- (void)gotoMakeSureTagSearchTime:(NSInteger)time  feerMoney:(NSInteger)feerMoney;
@end

@interface TagSearchView : UIView
- (void)createrTagSearchViewCity:(NSArray *)cityArray tagArray:(NSArray *)tagArray;
@property (nonatomic, weak) id<TagSearchViewDelegate>tagSearchViewDelegate;
@property (nonatomic ,strong)  UIView *timeBackView;
@property (nonatomic ,strong) UIView *moneyBackView;
@end
