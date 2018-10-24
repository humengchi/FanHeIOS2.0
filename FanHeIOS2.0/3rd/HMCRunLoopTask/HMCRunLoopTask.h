//
//  HMCRunLoopTask.h
//  test
//
//  Created by 胡梦驰 on 2018/7/13.
//  Copyright © 2018年 胡梦驰. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^RunloopBlock) (void);

@interface HMCRunLoopTask : NSObject

//添加任务
- (void)addTask:(RunloopBlock)task;

//开始定时器
- (void)startTimer;

//结束定时器
- (void)endTimer;

@end

