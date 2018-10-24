//
//  UITableSectionIndexView.h
//  ChannelPlus
//
//  Created by HuMengChi on 15/12/24.
//  Copyright © 2015年 Peter. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UITableSectionIndexViewDelegate;

@interface UITableSectionIndexView : UIView

@property (nonatomic, weak) id<UITableSectionIndexViewDelegate>delegate;

- (id)initWithFrame:(CGRect)frame sectionArray:(NSMutableArray*)sectionArray;
- (void)loadView:(NSMutableArray*)sectionArray;
- (void)changeBtnIndex:(NSInteger)index;


@end

@protocol UITableSectionIndexViewDelegate <NSObject>

- (void)indexViewChangeToIndex:(NSInteger)index;

@end
