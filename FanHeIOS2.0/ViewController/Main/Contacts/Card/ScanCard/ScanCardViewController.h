//
//  ScanCardViewController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/14.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

@interface ScanCardViewController : BaseViewController

@property (nonatomic, strong) UIImage *imageData;
@property (nonatomic, assign) BOOL isMyCard;
@property (nonatomic, strong) NSNumber *cardId;//编辑我的名片，重新扫描
@property (nonatomic, assign) BOOL isRegister;//注册

@end
