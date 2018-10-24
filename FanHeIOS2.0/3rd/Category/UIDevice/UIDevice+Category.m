//
//  UIDevice+Category.m
//  ChannelPlus
//
//  Created by Rookie Wang on 15/6/2.
//  Copyright (c) 2015年 Peter. All rights reserved.
//

#import "UIDevice+Category.h"

@implementation UIDevice (Category)

+ (NSNumber *) getDiskSpaceByTotalInBytes {
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    NSNumber *num = [fattributes objectForKey:NSFileSystemSize];
    
    return num;
}

+ (NSNumber *) getDiskSpaceByFreeInBytes {
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    NSNumber *num = [fattributes objectForKey:NSFileSystemFreeSize];
    
    return num;
}


@end
