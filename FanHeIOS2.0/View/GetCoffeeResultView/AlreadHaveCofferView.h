//
//  AlreadHaveCofferView.h
//  FanHeIOS2.0
//
//  Created by renhao on 2016/11/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlreadHaveCofferView : UIView
typedef void(^CheckGetCofferDetail)();

@property (nonatomic, strong) CheckGetCofferDetail checkGetCofferDetail;
@end
