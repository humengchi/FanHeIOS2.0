//
//  VisitPhoneBookView.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/11/8.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "VisitPhoneBookView.h"

@implementation VisitPhoneBookView

- (void)awakeFromNib{
    [super awakeFromNib];
}

#pragma mark - 跳转到手机通讯录
- (IBAction)gotoPhoneBookButtonClicked:(id)sender{
    if(self.visitPhoneBookViewResult){
        self.visitPhoneBookViewResult(YES);
    }
    [self removeFromSuperview];
}

#pragma mark - 取消
- (IBAction)cancleButtonClicked:(id)sender{
    if(self.visitPhoneBookViewResult){
        self.visitPhoneBookViewResult(NO);
    }
    [self removeFromSuperview];
}

@end
