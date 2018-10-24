//
//  PickerDatas.m
//  相册Demo
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ZLPhotoPickerDatas.h"
#import "ZLPhotoPickerGroup.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface ZLPhotoPickerDatas ()

@property (nonatomic , strong) ALAssetsLibrary *library;

@end

@implementation ZLPhotoPickerDatas

+ (ALAssetsLibrary *)defaultAssetsLibrary{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred,^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

- (ALAssetsLibrary *)library{
    if (nil == _library) {
        _library = [self.class defaultAssetsLibrary];
    }
    return _library;
}

#pragma mark - getter
+ (instancetype)defaultPicker{
    return [[self alloc] init];
}

#pragma mark -获取所有组
- (void)getAllGroupWithPhotos:(callBackBlock )callBack{
    if (IOS_X < 8.0f) {
        [self getAllGroupAllPhotosByALAssetsLibrary:YES withResource:callBack];
    }else {
        [self getAllGroupAllPhotosByPHPhotoLibrary:YES withResource:callBack];
    }
}

- (void)getAllGroupAllPhotosByALAssetsLibrary:(BOOL)allPhotos withResource:(callBackBlock)callBack{
    NSMutableArray *groups = [NSMutableArray array];
    ALAssetsLibraryGroupsEnumerationResultsBlock resultBlock = ^(ALAssetsGroup *group, BOOL *stop){
        if (group) {
            if (allPhotos){
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            }else{
                [group setAssetsFilter:[ALAssetsFilter allVideos]];
            }
            // 包装一个模型来赋值
            ZLPhotoPickerGroup *pickerGroup = [[ZLPhotoPickerGroup alloc] init];
            pickerGroup.alGroup = group;
            pickerGroup.groupName = [group valueForProperty:@"ALAssetsGroupPropertyName"];
            pickerGroup.thumbImage = [UIImage imageWithCGImage:[group posterImage]];
            pickerGroup.assetsCount = [group numberOfAssets];
            [groups addObject:pickerGroup];
        }else{
            callBack(groups);
        }
    };
    
    NSInteger type = ALAssetsGroupAll;
    
    [self.library enumerateGroupsWithTypes:type usingBlock:resultBlock failureBlock:nil];
}

- (void)getAllGroupAllPhotosByPHPhotoLibrary:(BOOL)allPhotos withResource:(callBackBlock)callBack{
    NSMutableArray *groups = [NSMutableArray array];
    
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d", PHAssetMediaTypeImage];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    PHFetchResult *smtR = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    PHAssetCollection *smtCol  = [smtR lastObject];
    PHFetchResult *smtFR = [PHAsset fetchAssetsInAssetCollection:smtCol options:option];
    if(IOS_X>=9.0){
        if([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    callBack(nil);
                }
            }];
        }
    }else{
        if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined) {
            ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if (*stop) {
                    callBack(nil);
                    return;
                }
                *stop = TRUE;//不能省略
            } failureBlock:^(NSError *error) {
//                NSLog(@"failureBlock");
            }];
        }
    }
    ZLPhotoPickerGroup *smtGroup = [[ZLPhotoPickerGroup alloc] init];
    smtGroup.phGroup = smtFR;
    smtGroup.groupName = smtCol.localizedTitle;
    smtGroup.assetsCount = smtFR.count;
    [self getThumbImage:smtGroup completion:^(BOOL ret, id obj) {
            smtGroup.thumbImage = obj;
    }];
    if (smtFR.count) [groups addObject:smtGroup];
    
#ifdef __IPHONE_9_0
    if (IOS_X >= 9.0f) {
        PHFetchResult *srnR = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumScreenshots options:nil];
        PHAssetCollection *srnCol   = [srnR lastObject];
        PHFetchResult *srnFR = [PHAsset fetchAssetsInAssetCollection:srnCol options:option];
        ZLPhotoPickerGroup *srnGroup = [[ZLPhotoPickerGroup alloc] init];
        srnGroup.phGroup = srnFR;
        srnGroup.groupName = srnCol.localizedTitle;
        srnGroup.assetsCount = srnFR.count;
        [self getThumbImage:srnGroup completion:^(BOOL ret, id obj) {
            srnGroup.thumbImage = obj;
        }];
        if (srnFR.count) [groups addObject:srnGroup];
    }
#endif
    
    PHAssetCollectionSubtype subType = PHAssetCollectionSubtypeAlbumRegular | PHAssetCollectionSubtypeAlbumSyncedAlbum;
    PHFetchResult *albumR = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:subType options:nil];
    for (PHAssetCollection *col in albumR) {
        @autoreleasepool
        {
            PHFetchResult *albumFR = [PHAsset fetchAssetsInAssetCollection:col options:option];
            ZLPhotoPickerGroup *albumGroup = [[ZLPhotoPickerGroup alloc] init];
            albumGroup.phGroup = albumFR;
            albumGroup.groupName = col.localizedTitle;
            albumGroup.assetsCount = albumFR.count;
            [self getThumbImage:albumGroup completion:^(BOOL ret, id obj) {
                    albumGroup.thumbImage = obj;
            }];
            if (albumFR.count) [groups addObject:albumGroup];
        }
    }
    
    callBack(groups);
}

- (void)getThumbImage:(ZLPhotoPickerGroup *)group
                       completion:(void (^)(BOOL ret, id obj))completion{
    PHAsset *asset = [group.phGroup firstObject];
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    
    CGFloat scale = [UIScreen mainScreen].scale; CGFloat dimension = 60.f;
    CGSize  size  = CGSizeMake(dimension * scale, dimension * scale);
    [[PHImageManager defaultManager] requestImageForAsset:asset
                            targetSize:size
                           contentMode:PHImageContentModeAspectFill
                               options:options
                         resultHandler:^(UIImage *result, NSDictionary *info)
    {
        completion((result != nil), result);
    }];
}

- (void)getImageForPHAsset:(PHAsset *)asset
                  withSize:(CGSize)size
                completion:(void (^)(BOOL ret, UIImage *image))completion
{
    if (![asset isKindOfClass:[PHAsset class]])
    {
        completion(NO, nil); return;
    }
    
    NSInteger r = [UIScreen mainScreen].scale;
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    [options setSynchronous:YES]; // called exactly once
    
    [[PHImageManager defaultManager] requestImageForAsset:asset
                            targetSize:CGSizeMake(size.width*r, size.height*r)
                           contentMode:PHImageContentModeAspectFit
                               options:options
                         resultHandler:^(UIImage *result, NSDictionary *info)
     {
         completion(YES, result);
     }];
}

/**
 * 获取所有组对应的图片
 */
- (void)getAllGroupWithVideos:(callBackBlock)callBack {
    [self getAllGroupAllPhotosByALAssetsLibrary:NO withResource:callBack];
}

#pragma mark -传入一个组获取组里面的Asset
- (void)getGroupPhotosWithGroup:(ZLPhotoPickerGroup *)pickerGroup finished: (callBackBlock )callBack{
    if (IOS_X < 8.0f) {
        [self getGroupPhotosWithGroupByALAssetsLibrary:pickerGroup finished:callBack];
    }else {
        [self getGroupPhotosWithGroupByPHPhotoLibrary:pickerGroup finished:callBack];
    }
}

- (void)getGroupPhotosWithGroupByALAssetsLibrary:(ZLPhotoPickerGroup *) pickerGroup finished:(callBackBlock )callBack{
    NSMutableArray *assets = [NSMutableArray array];
    ALAssetsGroupEnumerationResultsBlock result = ^(ALAsset *asset , NSUInteger index , BOOL *stop){
        if (asset) {
            [assets addObject:asset];
        }else{
            callBack(assets);
        }
    };
    [pickerGroup.alGroup enumerateAssetsUsingBlock:result];
}

- (void)getGroupPhotosWithGroupByPHPhotoLibrary:(ZLPhotoPickerGroup *) pickerGroup finished:(callBackBlock )callBack{
    
    callBack(pickerGroup.phGroup);
}

#pragma mark -传入一个AssetsURL来获取UIImage
- (void)getAssetsPhotoWithURLs:(NSURL *) url callBack:(callBackBlock ) callBack{
    [self.library assetForURL:url resultBlock:^(ALAsset *asset) {
        dispatch_async(dispatch_get_main_queue(), ^{
            callBack([UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]]);
        });
    } failureBlock:nil];
}

@end
