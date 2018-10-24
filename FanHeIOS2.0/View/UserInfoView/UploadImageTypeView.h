//
//  UploadImageTypeView.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/24.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, UploadImageTypeViewType) {
    UploadImageTypeViewType_UploadHeaderImage,
    UploadImageTypeViewType_UploadVideo,
    UploadImageTypeViewType_UploadNormalImage,
    UploadImageTypeViewType_UploadNoEditImage,
};

typedef void(^UploadHeaderImageViewResult)(BOOL success);

typedef void(^UploadImageViewImage)(UIImage *image);

typedef void(^UploadVideoViewType)(NSInteger type);

typedef void(^DeleteloadImageViewType)();

typedef void(^CancleLoadImageViewType)();

@interface UploadImageTypeView : UIView

@property (weak, nonatomic) IBOutlet UIButton *deleImageBtn;

@property (nonatomic, strong) UploadHeaderImageViewResult uploadHeaderImageViewResult;
@property (nonatomic, strong) UploadImageViewImage uploadImageViewImage;
@property (nonatomic, strong) DeleteloadImageViewType deleteloadImageViewType;
@property (nonatomic, strong) UploadVideoViewType uploadVideoViewType;
@property (nonatomic, strong) CancleLoadImageViewType cancleLoadImageViewType;
@property (nonatomic, assign) BOOL isIndentify;

- (void)setUploadImageTypeViewType:(UploadImageTypeViewType)type;

- (void)showShareNormalView;

@end
