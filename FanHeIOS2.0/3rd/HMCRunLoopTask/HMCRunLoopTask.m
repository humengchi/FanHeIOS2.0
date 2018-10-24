//
//  HMCRunLoopTask.m
//  test
//
//  Created by 胡梦驰 on 2018/7/13.
//  Copyright © 2018年 胡梦驰. All rights reserved.
//

#import "HMCRunLoopTask.h"

#define MaxTaskCount 10
@interface HMCRunLoopTask()

@property (nonatomic, strong) NSMutableArray *taskArray;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation HMCRunLoopTask

- (instancetype)init{
    if(self=[super init]){
        self.taskArray = [NSMutableArray array];
        [self addRunloopObverser];
    }
    return self;
}

- (void)timerMethod{
    //什么事情也不做!
//    NSLog(@"runlooptask timer 还在repeat，没有杀掉");
}

//开始定时器
- (void)startTimer{
    if(self.timer){
        [self.timer invalidate];
        self.timer = nil;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.0001 target:self selector:@selector(timerMethod) userInfo:nil repeats:YES];
}

//结束定时器
- (void)endTimer{
    [self.timer invalidate];
}

#pragma mark - <关于C语言Runloop>
//添加任务
- (void)addTask:(RunloopBlock)task{
    [self.taskArray addObject:task];
    if(self.taskArray.count > MaxTaskCount){
        [self.taskArray removeObjectAtIndex:0];
    }
}
//回调方法
static void callBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
    HMCRunLoopTask *vc = (__bridge HMCRunLoopTask*)info;
    if(vc.taskArray.count==0){
        return;
    }
    RunloopBlock task = vc.taskArray.firstObject;
    task();
    [vc.taskArray removeObjectAtIndex:0];
}

//添加Runloop
- (void)addRunloopObverser{
    //拿到当前的Runloop
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    CFRunLoopObserverContext context = {
        0,
        (__bridge void *)(self),
        &CFRetain,
        &CFRelease,
        NULL
    };
    
    //定义一个观察者,static内存中只存在一个
    static CFRunLoopObserverRef obverser;
    //创建一个观察者
    obverser = CFRunLoopObserverCreate(NULL, kCFRunLoopAfterWaiting, YES, 0, &callBack, &context);
    //添加观察者！！！
    CFRunLoopAddObserver(runloop, obverser, kCFRunLoopCommonModes);
    
    //release
    CFRelease(obverser);
}

@end
