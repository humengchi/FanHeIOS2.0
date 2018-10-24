//
//  CommonUIAlert.m
//  ChannelPlus
//
//  Created by apple on 15/11/16.
//  Copyright (c) 2015年 Peter. All rights reserved.
//
#import <objc/runtime.h>
#import "CommonUIAlert.h"

typedef void (^confirmBlock)();
typedef void (^cancleBlock)();

@interface CommonUIAlert()
@end

@implementation CommonUIAlert

-(void)showCommonAlertView:(UIViewController *)viewController title:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle cancle:(void (^)())cancle confirm:(void (^)())confirm{
    if(!confirm){
        confirm = ^(){};
    }
    if (!cancle) {
        cancle = ^(){};
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        if (otherButtonTitle == nil && cancelButtonTitle == nil) {
            cancelButtonTitle = @"确定";
        }
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        if (otherButtonTitle) {
            UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                confirm();
            }];
            [alertController addAction:otherAction];
        }
        
        if (cancelButtonTitle) {
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                cancle();
            }];
            [alertController addAction:cancelAction];
        }
        [viewController presentViewController:alertController animated:YES completion:nil];
    }else{
        if (otherButtonTitle == nil && cancelButtonTitle == nil) {
            [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        }else{
            if (cancelButtonTitle == nil || otherButtonTitle == nil) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                        message:message
                                                              cancelButtonTitle:nil
                                                      otherButtonTitles:otherButtonTitle?otherButtonTitle:cancelButtonTitle, nil];

                [alert setHandler:^(UIAlertView* alert, NSInteger buttonIndex) {
                    if(otherButtonTitle){
                        confirm();
                    }else{
                        cancle();
                    }
                } forButtonAtIndex:0];
                [alert show];
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                message:message
                                                      cancelButtonTitle:cancelButtonTitle
                                                      otherButtonTitles:otherButtonTitle, nil];
                [alert setHandler:^(UIAlertView* alert, NSInteger buttonIndex) {
                    confirm();
                } forButtonAtIndex:[alert firstOtherButtonIndex]];
                
                [alert setHandler:^(UIAlertView* alert, NSInteger buttonIndex) {
                    cancle();
                } forButtonAtIndex:0];
                [alert show];
            }
        }
    }
}

- (void)showCommonAlertView:(UIViewController *)viewController message:(NSString *)message{
    [self showCommonAlertView:viewController title:@"" message:message cancelButtonTitle:nil otherButtonTitle:nil cancle:nil confirm:nil];
}

@end
