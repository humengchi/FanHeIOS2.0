//
//  ZLAssets.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 15-1-3.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface ZLPhotoAssets : NSObject

@property (strong,nonatomic) ALAsset *alAsset;
@property (strong,nonatomic) PHAsset *phAsset;

/**
 *  缩略图
 */
- (UIImage *)aspectRatioImage;
/**
 *  缩略图
 */
- (UIImage *)thumbImage;
/**
 *  原图
 */
- (UIImage *)originImage;

- (void)setOriginImage:(UIImage *)originImage;
/**
 *  获取是否是视频类型, Default = false
 */
@property (assign,nonatomic) BOOL isVideoType;
/**
 *  获取图片的URL
 */
- (NSURL *)assetURL;

@end
