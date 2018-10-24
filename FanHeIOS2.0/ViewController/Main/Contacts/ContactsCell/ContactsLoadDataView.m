//
//  ContactsLoadDataView.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ContactsLoadDataView.h"

@interface  ContactsLoadDataView (){
    NSInteger _waitSecond;
}

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ContactsLoadDataView

- (void)setProgressing:(NSTimer*)timer{
    if(self.progressView.progress < 0.8){
        self.progressView.progress += 0.05;
    }
    if((_waitSecond++*0.3) >= 10){
        [self.timer invalidate];
        self.timer = nil;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(self.requestOvertime){
                self.requestOvertime();
            }
            [self removeFromSuperview];
        });
    }
}

- (void)startProgressing{
    [self.timer invalidate];
    self.timer = nil;
    _waitSecond = 0;
    self.timer = [NSTimer timerWithTimeInterval:0.3 target:self selector:@selector(setProgressing:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

- (void)stopProgressing{
    [self.timer invalidate];
    self.timer = nil;
    [self removeFromSuperview];
}

- (void)setProgressFinished{
    [self.timer invalidate];
    self.timer = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = 1;
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
    });
}

@end
