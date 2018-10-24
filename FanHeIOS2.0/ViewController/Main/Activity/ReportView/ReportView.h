//
//  ReportView.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/5/4.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportView : UIView
- (void)createrReport:(NSMutableArray *)array isAllShow:(BOOL)isAllShow;
@property (nonatomic ,strong) NSMutableArray *reportArray;
@property (nonatomic ,assign) BOOL isMore;
@end
