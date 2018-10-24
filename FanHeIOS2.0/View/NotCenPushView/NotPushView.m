//
//  NotPushView.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/11/11.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "NotPushView.h"

@implementation NotPushView
- (void)createrPushView:(NSString *)imageStr{
    UIView *coverView = [NSHelper createrViewFrame:CGRectMake(50, HEIGHT/2- (WIDTH - 100)/2, WIDTH - 100, WIDTH - 80) backColor:@"FFFFFF"];
    coverView.layer.masksToBounds = YES;
    coverView.layer.cornerRadius = 5;
    UIButton *backBtn = [NSHelper createButton:CGRectMake(coverView.frame.size.width - 20- 6,0 , 20, 20) title:nil unSelectImage:[UIImage imageNamed:@"btn_close_gray"] selectImage:nil target:self selector:@selector(remove)];
       [coverView addSubview:backBtn];
    UIButton *btn = [NSHelper createButton:CGRectMake(0, 0, coverView.frame.size.width , 20) title:nil unSelectImage:nil selectImage:nil target:self selector:@selector(remove)];
    btn.backgroundColor = [UIColor clearColor];
    [coverView addSubview:btn];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageTap)];
    [coverView addGestureRecognizer:tap];
                     
     UIImageView *imageView = [UIImageView drawImageViewLine:CGRectMake(0, 20,coverView.frame.size.width, coverView.frame.size.height - 20) bgColor:[UIColor clearColor]];
    [imageView sd_setImageWithURL:[NSURL URLWithString:imageStr] placeholderImage:nil];
    [coverView addSubview:imageView];
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 1;
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [coverView.layer addAnimation:animation forKey:nil];
    
    self.backgroundColor = [UIColor colorWithRed:65.0/255.0 green:70.0/255.0 blue:78.0/255 alpha:0.7];
   
    [self addSubview:coverView];
}
- (void)remove{
    if (self.notPushViewDelegate && [self.notPushViewDelegate respondsToSelector:@selector(removeWindow)]) {
        [self.notPushViewDelegate removeWindow];
    }
    
}
- (void)imageTap{
    if (self.notPushViewDelegate && [self.notPushViewDelegate respondsToSelector:@selector(tapImageAction)]) {
        [self.notPushViewDelegate tapImageAction];
    }
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
