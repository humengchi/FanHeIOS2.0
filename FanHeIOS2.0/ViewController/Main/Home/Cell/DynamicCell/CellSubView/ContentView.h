//
//  ContentView.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/3/1.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentView : UIView


@property (nonatomic, strong) NSNumber *dynamicId;

- (void)updateDisplay:(NSString*)content isShare:(BOOL)isShare dynamicId:(NSNumber*)dynamicId dynamicModel:(DynamicModel*)model;

@end
