//
//  MCScrollView.h
//  Promotion
//
//  Created by HuMengChi on 15/6/24.
//  Copyright (c) 2015年 hmc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MCScrollViewClickIndex)(NSInteger index);

@interface MCScrollView : UIView

@property (nonatomic, strong) MCScrollViewClickIndex scrollViewClickIndex;

- (id)initWithFrame:(CGRect)frame ParameterArray:(NSArray*)array;

//开启自动循环
- (void)startTimer;
//关闭自动循环
- (void)endTimer;

- (void)updateDisplay:(NSArray*)array;

@end
