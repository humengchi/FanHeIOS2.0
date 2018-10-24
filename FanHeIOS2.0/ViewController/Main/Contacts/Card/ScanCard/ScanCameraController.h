//
//  ScanCameraController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/14.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

@interface ScanCameraController : BaseViewController

@property (nonatomic, assign) BOOL isMyCard;
@property (nonatomic, assign) BOOL isRegister; //注册
@property (nonatomic, strong) NSNumber *cardId;//编辑我的名片，重新扫描

@end
