//
//  ChoiceAddressView.h
//  JinMai
//
//  Created by 胡梦驰 on 16/5/11.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectAddress) (NSString *provinceId, NSString *cityId, NSString *districtId);

@interface ChoiceAddressView : UIView

@property (nonatomic, strong) SelectAddress selectAddress;

- (void)updateDisplay:(NSString*)provinceId cityId:(NSString*)cityId districtId:(NSString*)districtId;

- (void)showShareNormalView;

@end
