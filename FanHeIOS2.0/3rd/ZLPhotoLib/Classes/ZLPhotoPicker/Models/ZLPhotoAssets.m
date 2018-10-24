//
//  ZLAssets.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 15-1-3.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

#import "ZLPhotoAssets.h"

@interface ZLPhotoAssets()

@property (nonatomic, strong) UIImage *photoImage;

@end

@implementation ZLPhotoAssets

- (UIImage *)aspectRatioImage{
    if (IOS_X < 8.0f) {
        return [UIImage imageWithCGImage:[self.alAsset aspectRatioThumbnail]];
    }
    return nil;
}

- (UIImage *)thumbImage{
    if (IOS_X < 8.0f) {
        return [UIImage imageWithCGImage:[self.alAsset thumbnail]];
    }
    return nil;
}

- (UIImage *)originImage{
    if (IOS_X < 8.0f) {
        return [UIImage imageWithCGImage:[[self.alAsset defaultRepresentation] fullScreenImage]];
    }
    return _photoImage;
}

- (void)setOriginImage:(UIImage *)originImage {
    _photoImage = originImage;
}

- (BOOL)isVideoType{
    NSString *type = [self.alAsset valueForProperty:ALAssetPropertyType];
    //媒体类型是视频
    return [type isEqualToString:ALAssetTypeVideo];
}

- (NSURL *)assetURL{
    return [[self.alAsset defaultRepresentation] url];
}

@end
