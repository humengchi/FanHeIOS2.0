//
//  ScanQRCodeViewController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/11/25.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

@protocol ScanQRCodeViewControllerDelegate <NSObject>

- (void)ScanQRCodeViewControllerDelegateResult:(NSString*)symbolsStr;

@end

@interface ScanQRCodeViewController : BaseViewController

@property (nonatomic, weak) id<ScanQRCodeViewControllerDelegate> delegate;

@end
