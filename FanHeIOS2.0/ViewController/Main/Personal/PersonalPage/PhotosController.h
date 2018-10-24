//
//  PhotosController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/18.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

@interface PhotosController : BaseViewController

@property (nonatomic, strong) NSNumber *userId;

@property (nonatomic, strong) void(^photosChange)(NSMutableArray *array);

@end
