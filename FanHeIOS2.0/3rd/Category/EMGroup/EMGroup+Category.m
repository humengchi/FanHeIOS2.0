//
//  EMGroup+Category.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/25.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "EMGroup+Category.h"

//@interface EMGroup (Category)
//
//@property (nonatomic, strong) UIImage *headerImage;
//@property (nonatomic, strong) NSNumber *hasCreated;
//@property (nonatomic, strong) NSNumber *isMyGroupList;
//
//@end

static UIImage *_headerImage;
static UIImage *_hasCreated;
static UIImage *_isMyGroupList;

@implementation EMGroup(Category)

- (void)setHeaderImage:(UIImage*)headerImage{
    objc_setAssociatedObject(self, &_headerImage, headerImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage*)headerImage{
    return objc_getAssociatedObject(self, &_headerImage);
}

- (void)setHasCreated:(NSNumber*)hasCreated{
    objc_setAssociatedObject(self, &_hasCreated, hasCreated, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber*)hasCreated{
    return objc_getAssociatedObject(self, &_hasCreated);
}

- (void)setIsMyGroupList:(NSNumber*)isMyGroupList{
    objc_setAssociatedObject(self, &_isMyGroupList, isMyGroupList, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber*)isMyGroupList{
    return objc_getAssociatedObject(self, &_isMyGroupList);
}

@end
