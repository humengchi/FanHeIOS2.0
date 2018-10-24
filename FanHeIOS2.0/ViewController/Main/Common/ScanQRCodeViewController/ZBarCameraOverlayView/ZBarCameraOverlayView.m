//
//  ZBarCameraOverlayView.m
//  ChannelPlus
//
//  Created by Rookie Wang on 15/11/24.
//  Copyright © 2015年 Peter. All rights reserved.
//

#import "ZBarCameraOverlayView.h"

@interface ZBarCameraOverlayView()

@property (nonatomic, assign)CGFloat startX;
@property (nonatomic, assign)CGFloat startY;
@property (nonatomic, assign)CGFloat width;
@property (nonatomic, assign)CGFloat height;
@property (nonatomic, strong)UIImageView *moveLine;

@end

@implementation ZBarCameraOverlayView

- (instancetype)initWithFrame:(CGRect)frame scanMaskFrame:(CGRect)scanMaskFrame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _startX = scanMaskFrame.origin.x;
        _startY = scanMaskFrame.origin.y;
        _width = scanMaskFrame.size.width;
        _height = scanMaskFrame.size.height;
        
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [backBtn setFrame:CGRectMake(10, 22, 60, 40)];
        [backBtn setImage:kImageWithName(@"navBack") forState:UIControlStateNormal];
        [backBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:backBtn];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, WIDTH, 30)];
        titleLabel.text = @"请将二维码对准扫码框";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:titleLabel];
        
        UILabel *viewTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 20, WIDTH-80, 44)];
        viewTitleLabel.text = @"扫一扫";
        viewTitleLabel.textAlignment = NSTextAlignmentCenter;
        viewTitleLabel.font = [UIFont systemFontOfSize:18];
        viewTitleLabel.textColor = [UIColor whiteColor];
        viewTitleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:viewTitleLabel];
        
        [self startAnimation];
    }
    return self;
}

- (void)back {
    [[self viewController].navigationController popViewControllerAnimated:YES];
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 0, 0, 0, 0.6f);
    
    CGRect notRecoginitonRect = CGRectMake(0, 0, WIDTH, _startY);
    CGContextFillRect(context, notRecoginitonRect);
    
    notRecoginitonRect = CGRectMake(0, _startY, _startX, _height);
    CGContextFillRect(context, notRecoginitonRect);
    
    notRecoginitonRect = CGRectMake(_startX+_width, _startY, _startX, _height);
    CGContextFillRect(context, notRecoginitonRect);
    
    notRecoginitonRect = CGRectMake(0, _startY+_height, WIDTH, HEIGHT-_startY-_height);
    CGContextFillRect(context, notRecoginitonRect);
    CGContextStrokePath(context);
    
    UIImage *image = kImageWithName(@"barcode_back");
    [image drawInRect:CGRectMake(_startX, _startY, _width, _height)];
}

- (void)startAnimation {
    if (_moveLine == nil) {
        _moveLine = [[UIImageView alloc] init];
        _moveLine.image = kImageWithName(@"barcode_line");
        [self addSubview:_moveLine];
    }
    _moveLine.frame = CGRectMake(_startX, _startY, _width, 2);
    
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:2.f animations:^{
        weakSelf.moveLine.frame = CGRectMake(_startX, _startY+_height-2, _width, 2);
    } completion:^(BOOL finished) {
        [weakSelf performSelector:@selector(startAnimation) withObject:nil afterDelay:0.3f];
    }];
}

@end
