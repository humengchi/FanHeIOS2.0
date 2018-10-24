//
//  UIImage+SHDQ.h
//  SHDQ
//
//  Created by Peter on 14-10-2.
//  Copyright (c) 2014年 com.shdq. All rights reserved.
//

#import <UIKit/UIKit.h>

#define HEX_IMAGE(x)    [UIImage createImageWithColor:(HEX_COLOR(x))]
#define HEX_IMAGE_RECT(x,rect)    [UIImage createImageWithColor:(HEX_COLOR(x)) withRect:rect]

#define kImageWithName(x)   [UIImage imageNamed:(x)]

#define kImageWithColor(x,y) [UIImage createImageWithColor:(x) withRect:(y)]

#define KCreateImageWithUserId(str) [UIImage createImageWithString:[[IMMsgDBAccess sharedInstance] getUserName:(str)]]

@interface UIImage (SHDQ)
+ (UIImage *)createImageWithColor:(UIColor *)color;
+ (UIImage *)createImageWithColor:(UIColor *)color withRect:(CGRect )rect;
+ (UIImage *)resizeImageWithRect:(UIImage *)image;
- (UIImage *)imageWithColor:(UIColor *)color;//改变颜色
//图片添加水印
//- (UIImage *)createWatermarkImage:(NSString *)leftTopStr rightTopStr:(NSString *)rightTopStr leftBottomStr1:(NSString *)leftBottomStr1 leftBottomStr2:(NSString *)leftBottomStr2;
- (UIImage *)createWatermarkImage:(NSString *)leftTopStr rightTopStr:(NSString *)rightTopStr leftBottomStr1:(NSString *)leftBottomStr1 leftBottomStr2:(NSString *)leftBottomStr2 markDate:(NSDate *)markDate;
//裁剪图片
- (UIImage *)roundedCornerImageWithCornerRadius:(CGRect)cornerRadius;
#pragma mark - 获取视频第一帧图片
+ (UIImage*)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;

+ (UIImage *) createImageWithString: (NSString *) string;

+ (UIImage *)createImageWithUserModelArray:(NSArray *)modelArray;

- (UIImage *)scaleToSize:(CGFloat)width;

- (UIImage *)scaleToSquareSize:(CGFloat)width;

+ (UIImage *)createHeaderImageWithString:(NSString *) string;

+ (UIImage *)resizeImageWithRectNine:(UIImage *)image;
//修复图片旋转
+ (UIImage *)fixOrientation:(UIImage *)srcImg;
@end
