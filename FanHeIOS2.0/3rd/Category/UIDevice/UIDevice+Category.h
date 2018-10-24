//
//  UIDevice+Category.h
//  ChannelPlus
//
//  Created by Rookie Wang on 15/6/2.
//  Copyright (c) 2015年 Peter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (Category)

+ (NSNumber *) getDiskSpaceByTotalInBytes;

+ (NSNumber *) getDiskSpaceByFreeInBytes;

@end
