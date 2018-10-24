//
//  ChatViewController.h
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/26.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#define KNOTIFICATIONNAME_DELETEALLMESSAGE @"RemoveAllMessages"

@interface ChatViewController : EaseMessageViewController
@property (nonatomic ,assign)   BOOL isRefer;
@property (nonatomic ,strong)  NSString *position;
@property (nonatomic ,strong)  NSString *phoneNumber;
@property (nonatomic, assign)  NSInteger pushIndex;
@property (nonatomic ,assign)  BOOL isBack;

@end
