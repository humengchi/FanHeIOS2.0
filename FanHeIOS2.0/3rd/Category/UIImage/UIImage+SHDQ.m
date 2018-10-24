//
//  UIImage+SHDQ.m
//  SHDQ
//
//  Created by Peter on 14-10-2.
//  Copyright (c) 2014年 com.shdq. All rights reserved.
//

#import "UIImage+SHDQ.h"

@implementation UIImage (SHDQ)

+ (UIImage *) createImageWithColor: (UIColor *) color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *) createImageWithColor: (UIColor *) color withRect:(CGRect )rect
{
    //    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *)resizeImageWithRect:(UIImage *)image
{
    CGSize imageSize = image.size;
    CGSize size;
    CGRect rect;
    if(imageSize.height<imageSize.width){
        size = CGSizeMake(imageSize.width, imageSize.width);
        rect = CGRectMake(0, (imageSize.width-imageSize.height)/2, imageSize.width, imageSize.height);
    }else{
        size = CGSizeMake(imageSize.height, imageSize.height);
        rect = CGRectMake((imageSize.height-imageSize.width)/2, 0, imageSize.width, imageSize.height);
    }
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    
    //背景颜色
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [BLACK_COLOR CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.width));
    
    // 绘制改变大小的图片
    [image drawInRect:rect];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
    
}

+ (UIImage *)resizeImageWithRectNine:(UIImage *)image{
    CGSize size;
    CGSize imageSize = image.size;
    CGRect rect = CGRectMake(0, 0, imageSize.width, imageSize.height);
    if(imageSize.width>imageSize.height){
        size = CGSizeMake(imageSize.width, imageSize.width);
    }else{
        size = CGSizeMake(imageSize.height, imageSize.height);
    }
    
    UIGraphicsBeginImageContext(size);
    
    //背景颜色
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [WHITE_COLOR CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.width));
    
    // 绘制改变大小的图片
    [image drawInRect:rect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
    
}

- (UIImage *)imageWithColor:(UIColor *)color{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 2);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0005, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *) createWatermarkImage:(NSString *)leftTopStr rightTopStr:(NSString *)rightTopStr leftBottomFrontStr1:(NSString *)leftBottomStr1 leftBottomStr2:(NSString *)leftBottomStr2
{
    return [self createWatermarkImage:leftTopStr rightTopStr:rightTopStr leftBottomStr1:leftBottomStr1 leftBottomStr2:leftBottomStr2 markDate:[NSDate date]];
}

- (UIImage *)createWatermarkImage:(NSString *)leftTopStr rightTopStr:(NSString *)rightTopStr leftBottomStr1:(NSString *)leftBottomStr1 leftBottomStr2:(NSString *)leftBottomStr2 markDate:(NSDate *)markDate
{
    leftTopStr = !leftTopStr ? @"" : leftTopStr;
    rightTopStr = !rightTopStr ? @"" : rightTopStr;
    leftBottomStr1 = !leftBottomStr1 ? @"" : leftBottomStr1;
    leftBottomStr2 = !leftBottomStr2 ? @"" : leftBottomStr2;
    markDate = !markDate ? [NSDate date] : markDate;
    NSString *connSymbol = @"-";
    if ([leftBottomStr1 isEqualToString:@""] || [leftBottomStr2 isEqualToString:@""]) {
        connSymbol = @"";
    }
    NSString *leftBottomStr = [NSString stringWithFormat:@"%@%@%@",leftBottomStr1,connSymbol,leftBottomStr2];
    NSString *timeStr = [NSDate stringFromDate:markDate format:@"yyyy-MM-dd HH:mm:ss"];
    
    // 左右间距
    CGFloat defaultSpace = 20.0f;
    // 字体大小
    UIFont *font = [UIFont systemFontOfSize:15.0f];
    // 水印高度
    CGFloat waterMarkHeight = 40.0f;
    if (MAX(self.size.width, self.size.height) == 320.0) {
        font = [UIFont systemFontOfSize:9.0f];
        waterMarkHeight = 20.0f;
        defaultSpace = 6.0f;
    }else if (MAX(self.size.width, self.size.height) == 480.0) {
        font = [UIFont systemFontOfSize:13.0f];
        waterMarkHeight = 30.0f;
        defaultSpace = 12.0f;
    }else{
        if (self.size.width > self.size.height) {// 横屏图片
            font = [UIFont systemFontOfSize:20.0f];
            waterMarkHeight = 50.0f;
        }
    }
    
    CGFloat rightMaxWidth = self.size.width/2-defaultSpace;
    CGFloat rightWidth = self.size.width/2-defaultSpace;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentLeft;
    style.lineBreakMode = NSLineBreakByTruncatingTail;

    //文字的属性
    NSDictionary *dic = @{NSFontAttributeName:font,
                          NSParagraphStyleAttributeName:style,
                          NSForegroundColorAttributeName:[UIColor blackColor],
                          };
    
    CGSize timeSize = [timeStr boundingRectWithSize:CGSizeMake(rightMaxWidth,waterMarkHeight/2)
                                            options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading
                                         attributes:dic
                                            context:nil].size;
    CGSize rightTopSize = [rightTopStr boundingRectWithSize:CGSizeMake(rightMaxWidth,waterMarkHeight/2)
                                                    options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading
                                                 attributes:dic
                                                    context:nil].size;
    
    if (self.size.width > self.size.height) {// 横屏图片
        CGFloat theBigger = timeSize.width < rightTopSize.width ? rightTopSize.width : timeSize.width;
        rightWidth = theBigger < rightMaxWidth ? theBigger : rightMaxWidth;
    }else{// 竖屏图片
        rightWidth = timeSize.width < rightMaxWidth ? timeSize.width :rightMaxWidth;
    }
    
    // 计算右上端位置
    CGRect rightTopRect = CGRectMake(self.size.width-defaultSpace-rightWidth+5, self.size.height-waterMarkHeight, rightWidth, waterMarkHeight/2);
    // 计算右下端时间位置
    CGRect timeRect = CGRectMake(rightTopRect.origin.x, self.size.height-waterMarkHeight/2, rightWidth, waterMarkHeight/2);
    // 计算左上端位置
    CGRect leftTopRect = CGRectMake(defaultSpace, self.size.height-waterMarkHeight, rightTopRect.origin.x-defaultSpace, waterMarkHeight/2);
    // 计算左下端位置
    CGRect leftBottomRect = CGRectMake(defaultSpace, self.size.height-waterMarkHeight/2, rightTopRect.origin.x-defaultSpace, waterMarkHeight/2);
    
    UIGraphicsBeginImageContext(self.size);
    //原图
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height-waterMarkHeight)];
    // 添加背景白底
    CGRect rect = CGRectMake(0, self.size.height-waterMarkHeight, self.size.width, waterMarkHeight);
    [@"" drawInRect:rect withAttributes:@{NSBackgroundColorAttributeName:[UIColor whiteColor]}];
    // 添加右上端
    [rightTopStr drawInRect:rightTopRect withAttributes:dic];
    // 添加右下端时间
    [timeStr drawInRect:timeRect withAttributes:dic];
    // 添加左上端
    [leftTopStr drawInRect:leftTopRect withAttributes:dic];
    // 添加左下端
    [leftBottomStr drawInRect:leftBottomRect withAttributes:dic];
    
    UIImage *pic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return pic;
}

#pragma mark - 获取视频第一帧图片
+ (UIImage*)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    if(videoURL == nil){
        return kImageWithName(@"bg_coffee_chenggong");
    }
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];

    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
    
    return thumbnailImage;
}

+ (UIImage *) createImageWithString: (NSString *) string
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 46.0f, 46.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, HEX_COLOR(@"FBB58D").CGColor);
    CGContextFillRect(context, rect);
    
    //  写字
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes =@{NSFontAttributeName:[UIFont systemFontOfSize:18], NSForegroundColorAttributeName:[UIColor whiteColor],NSParagraphStyleAttributeName:paragraphStyle};
//    string = [string substringToIndex:1];
    float height = [NSHelper heightOfString:string font:[UIFont systemFontOfSize:18] width:46.0f];
    height = height>46.0f?46.0f:height;
    [string drawWithRect:CGRectMake(0, (46.0f-height)/2.0, 46.0f, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    //  画矩形
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGRect rectangle = CGRectMake(0, 0, 46.0f, 46.0f);
    CGContextAddRect(context, rectangle);
    CGContextStrokePath(context);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *)createImageWithUserModelArray:(NSArray *)modelArray{
    CGRect rect = CGRectMake(0.0f, 0.0f, 44.0f, 44.0f);
//    UIGraphicsBeginImageContext(rect.size);
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 2.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, HEX_COLOR(@"e6e6e6").CGColor);
    CGContextFillRect(context, rect);
    
    NSMutableArray *frameArray = [NSMutableArray array];
    if(modelArray.count == 1){
        CGRect frame = CGRectMake(13, 13, 18, 18);
        [frameArray addObject:[NSValue valueWithCGRect:frame]];
    }else if(modelArray.count == 2){
        CGRect frame1 = CGRectMake(0, 0, 22, 44);
        CGRect frame2 = CGRectMake(22, 0, 22, 44);
        [frameArray addObject:[NSValue valueWithCGRect:frame1]];
        [frameArray addObject:[NSValue valueWithCGRect:frame2]];
    }else if(modelArray.count == 3){
        CGRect frame1 = CGRectMake(0, 0, 22, 44);
        CGRect frame2 = CGRectMake(22, 0, 22, 22);
        CGRect frame3 = CGRectMake(22, 22, 22, 22);
        [frameArray addObject:[NSValue valueWithCGRect:frame1]];
        [frameArray addObject:[NSValue valueWithCGRect:frame2]];
        [frameArray addObject:[NSValue valueWithCGRect:frame3]];
    }else{
        CGRect frame1 = CGRectMake(0, 0, 22, 22);
        CGRect frame2 = CGRectMake(22, 0, 22, 22);
        CGRect frame3 = CGRectMake(0, 22, 22, 22);
        CGRect frame4 = CGRectMake(22, 22, 22, 22);
        [frameArray addObject:[NSValue valueWithCGRect:frame1]];
        [frameArray addObject:[NSValue valueWithCGRect:frame2]];
        [frameArray addObject:[NSValue valueWithCGRect:frame3]];
        [frameArray addObject:[NSValue valueWithCGRect:frame4]];
    }
    
    for(int i=0; i<frameArray.count; i++){
        GroupChartModel *model = modelArray[i];
        CGRect frame = [(NSValue*)frameArray[i] CGRectValue];
        UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:model.image]]];
        if(!image){
            image = KHeadImageDefaultName(model.realname);
        }
//        [image scaleToSize:frame.size.width];
        [image drawInRect:frame];
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path,NULL, frame);
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        CGContextAddPath(currentContext, path);
        [[UIColor clearColor] setFill];
        [[UIColor whiteColor] setStroke];
        CGContextSetLineWidth(currentContext,1.0f);
        CGContextDrawPath(currentContext, kCGPathFillStroke);
        CGPathRelease(path);
    }
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *)createHeaderImageWithString:(NSString *) string{
    string = [CommonMethod paramStringIsNull:string];
    if(string.length==0){
//        string = @"头像";
        return KHeadImageDefault;
    }else{
        string = [string substringFromIndex:string.length>2?string.length-2:0];
    }
    UIColor *bgColor;
    unichar word = [EaseChineseToPinyin sortSectionTitle:[[EaseChineseToPinyin pinyinFromChineseString:string] uppercaseString]];
    if(word>='A'&&word<='F'){
        bgColor = HEX_COLOR(@"1FB28A");
    }else if(word>='G'&&word<='M'){
        bgColor = HEX_COLOR(@"F16655");
    }else if(word>='N'&&word<='S'){
        bgColor = HEX_COLOR(@"069BF1");
    }else{
        bgColor = HEX_COLOR(@"E24943");
    }
    CGFloat width = WIDTH;
    CGFloat font = 6*width/17.0;
    CGRect rect = CGRectMake(0.0f, 0.0f, width, width);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, bgColor.CGColor);
    CGContextFillRect(context, rect);
    
    //  写字
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes =@{NSFontAttributeName:[UIFont systemFontOfSize:font], NSForegroundColorAttributeName:[UIColor whiteColor],NSParagraphStyleAttributeName:paragraphStyle};
    float height = font+30;
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:string attributes:attributes];
    [attr drawInRect:CGRectMake(0, (width-height)/2, width, height)];
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (UIImage *)scaleToSquareSize:(CGFloat)width{
    CGRect rect = CGRectMake((self.size.width-width)/2.0, (self.size.height-width)/2.0, width, width);
    CGImageRef subImageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    
    return smallImage;
}

- (UIImage *)scaleToSize:(CGFloat)width{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    CGSize size = CGSizeMake(width, self.size.height*width/self.size.width);
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

- (UIImage *)roundedCornerImageWithCornerRadius:(CGRect)cornerRadius {
    CGFloat w = cornerRadius.size.width;
    CGFloat h = w;
    CGSize size = CGSizeMake(w, w);
    UIImage *image = nil;
    CGRect imageFrame = CGRectMake(0., 0., w, h);
    UIGraphicsBeginImageContextWithOptions(size, NO, w);
    [[UIBezierPath bezierPathWithRoundedRect:imageFrame cornerRadius:w/2] addClip];
    [self drawInRect:imageFrame];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//修复图片旋转
+ (UIImage *)fixOrientation:(UIImage *)srcImg{
    if (srcImg.imageOrientation == UIImageOrientationUp) return srcImg;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (srcImg.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (srcImg.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, srcImg.size.width, srcImg.size.height,
                                             CGImageGetBitsPerComponent(srcImg.CGImage), 0,
                                             CGImageGetColorSpace(srcImg.CGImage),
                                             CGImageGetBitmapInfo(srcImg.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (srcImg.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.height,srcImg.size.width), srcImg.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.width,srcImg.size.height), srcImg.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
