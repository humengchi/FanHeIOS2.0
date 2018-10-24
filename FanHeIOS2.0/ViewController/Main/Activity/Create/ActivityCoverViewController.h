//
//  ActivityCoverViewController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/1/3.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^SelectedCover)(UIImage *coverIamge, NSString *imageUrl);

@interface ActivityCoverViewController : BaseViewController

@property (nonatomic, strong) SelectedCover selectedCover;

@end
