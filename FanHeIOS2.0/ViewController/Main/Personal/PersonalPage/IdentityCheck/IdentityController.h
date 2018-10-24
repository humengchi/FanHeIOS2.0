//
//  IdentityController.h
//  JinMai
//
//  Created by renhao on 16/5/12.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol IdentityControllerDelegate <NSObject>

- (void)referImageView:(UIImage *)image;

@end
@interface IdentityController : BaseViewController
@property (nonatomic ,weak) id<IdentityControllerDelegate>idDelegate;

@end
