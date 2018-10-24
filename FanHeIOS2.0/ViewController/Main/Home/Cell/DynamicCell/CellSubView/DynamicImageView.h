//
//  DynamicImageView.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/3/1.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DynamicImageView : UIView


@property (nonatomic, strong) DynamicModel *model;

- (id)initWithFrame:(CGRect)frame imageArray:(NSArray*)imageArray model:(DynamicModel*)model isShare:(BOOL)isShare;

@end
