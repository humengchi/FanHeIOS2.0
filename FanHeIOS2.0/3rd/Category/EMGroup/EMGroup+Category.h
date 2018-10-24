//
//  EMGroup+Category.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/25.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EMGroup(Category)

- (void)setHeaderImage:(UIImage*)headerImage;
- (UIImage*)headerImage;

- (void)setHasCreated:(NSNumber*)hasCreated;
- (NSNumber*)hasCreated;

- (void)setIsMyGroupList:(NSNumber*)isMyGroupList;
- (NSNumber*)isMyGroupList;

@end
