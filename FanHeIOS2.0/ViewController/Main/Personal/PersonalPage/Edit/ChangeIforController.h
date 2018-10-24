//
//  ChangeIforController.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/11/4.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChangeIforControllerDelegate <NSObject>

- (void)changeMyMessage:(NSString *)changeStr;

@end


@interface ChangeIforController : UIViewController

@property (nonatomic,assign)  NSInteger index;
@property (nonatomic,strong) NSString *titleStr;
@property (nonatomic,assign) id<ChangeIforControllerDelegate>changeDelegate;
@end
