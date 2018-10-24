//
//  BaseKeyboardViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/7/29.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseKeyboardViewController.h"

@interface BaseKeyboardViewController ()

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation BaseKeyboardViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backNavBtn.hidden = self.hideBackNavBtn;
    
    self.tapGesture = [CommonMethod viewAddGuestureRecognizer:self.view tapsNumber:1 withTarget:self withSEL:@selector(hideKeyboard)];
    // Do any additional setup after loading the view.
}

#pragma mark - Keyboard status
- (void)keyboardWillShowOrHide:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardEnd = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    CGFloat keyboardHeight = keyboardEnd.size.height;
    [UIView animateWithDuration:duration animations:^{
        if([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        }else{
        }
    }];
}

- (void)hideKeyboard{
    [self.view endEditing:YES];
}

- (void)removeViewTapGesture{
    [self.view removeGestureRecognizer:self.tapGesture];
}

@end
