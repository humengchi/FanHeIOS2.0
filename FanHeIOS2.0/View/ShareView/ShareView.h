//
//  ShareView.h
//  JinMai
//
//  Created by 胡梦驰 on 16/5/13.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ShareIndex)(NSInteger index);
@interface ShareView : UIView
@property (nonatomic,strong)UIView *shareView;
@property (nonatomic ,assign) BOOL isDynamic;
//@property (nonatomic, strong) ShareIndex shareIndex;
//- (void)showShareView;
@property (nonatomic,copy) void(^showShareViewIndex)(NSInteger index);
- (void)createrShareView;
@end
