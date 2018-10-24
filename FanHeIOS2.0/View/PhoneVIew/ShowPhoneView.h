//
//  ShowPhoneView.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/10/31.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^PhoneViewIndex)(NSInteger index);
@interface ShowPhoneView : UIView
@property (nonatomic ,strong) NSNumber *canviewphone;
@property (nonatomic,strong)NSString *phoneNumbStr;
@property (nonatomic,strong)NSString *weixinNumberStr;
@property (nonatomic,strong)NSString *emailStr;
@property (nonatomic,copy) void(^showPhoneViewIndex)(NSInteger index);
- (void)createrPhoneView;
@end
