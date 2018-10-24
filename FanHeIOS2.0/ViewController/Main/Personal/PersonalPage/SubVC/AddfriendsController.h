//
//  AddfriendsController.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/5.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseKeyboardViewController.h"

typedef void(^ExchangeSuccess) (BOOL success);

@interface AddfriendsController : BaseKeyboardViewController<AVAudioRecorderDelegate>
@property (nonatomic, strong)  NSString *phone;
@property (nonatomic, strong)  NSNumber *userID;
@property (nonatomic, strong) ExchangeSuccess exchangeSuccess;

@end
