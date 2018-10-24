//
//  UrlShowView.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/2/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UrlShowViewDelegate <NSObject>

- (void)gotoMakeUrl:(NSInteger)index;

@end

@interface UrlShowView : UIView

@property (nonatomic, weak) id<UrlShowViewDelegate>urlShowViewDelegate;
@property (nonatomic ,strong) UIImage *showImage;

- (void)createrUrlView:(NSArray *)urlArray;

@end
