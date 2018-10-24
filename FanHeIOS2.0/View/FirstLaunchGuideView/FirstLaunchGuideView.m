//
//  FirstLaunchGuideView.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/10/27.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "FirstLaunchGuideView.h"

@interface FirstLaunchGuideView ()

@property (nonatomic, weak) IBOutlet UIImageView *showImageView;
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation FirstLaunchGuideView

- (void)awakeFromNib{
    [super awakeFromNib];
    self.currentIndex = 0;
}

- (void)newUserGuide{
    CGPoint point = CGPointMake(0, 0);
    if(self.viewType == FLGV_Type_MyPage) {
        if(self.currentIndex==0){
            point = CGPointMake(34, 200*WIDTH/375.0+27);
        }
    }else if(self.viewType == FLGV_Type_Contact) {
        if(self.currentIndex==0){
            point = CGPointMake(WIDTH/5.0/2*3, 147);
        }else if(self.currentIndex==1){
            point = CGPointMake(WIDTH/5.0/2*5, 147);
        }else{
            point = CGPointMake(WIDTH/5.0/2*9, 147);
        }
    }else{
        if(self.currentIndex==0){
            if(WIDTH>375){
                point = CGPointMake(WIDTH-35, 40);
            }else{
                point = CGPointMake(WIDTH-31, 41);
            }
        }else if(self.currentIndex==1){
            point = CGPointMake(WIDTH-51, HEIGHT-100);
        }
    }
    CGRect frame = [UIScreen mainScreen].bounds;
    UIView * bgView = [[UIView alloc]initWithFrame:frame];
    bgView.backgroundColor = [HEX_COLOR(@"212325") colorWithAlphaComponent:0.8];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sureTapClick:)];
    [bgView addGestureRecognizer:tap];
    [self addSubview:bgView];
    
    //create path 重点来了（**这里需要添加第一个路径）
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:frame];
    // 这里添加第二个路径 （这个是圆）
    if (self.viewType == FLGV_Type_MyPage) {
        if (self.currentIndex == 0 ) {
            [path appendPath:[UIBezierPath bezierPathWithArcCenter:point radius:34 startAngle:0 endAngle:2*M_PI clockwise:NO]];
        }
    }else if (self.viewType == FLGV_Type_Contact) {
        if (self.currentIndex == 0) {
            [path appendPath:[UIBezierPath bezierPathWithArcCenter:point radius:27 startAngle:0 endAngle:2*M_PI clockwise:NO]];
        }else if (self.currentIndex == 1) {
            [path appendPath:[UIBezierPath bezierPathWithArcCenter:point radius:27 startAngle:0 endAngle:2*M_PI clockwise:NO]];
        }else{
            [path appendPath:[UIBezierPath bezierPathWithArcCenter:point radius:27 startAngle:0 endAngle:2*M_PI clockwise:NO]];
        }
    }else{
        if(self.currentIndex == 0) {
            [path appendPath:[UIBezierPath bezierPathWithArcCenter:point radius:20 startAngle:0 endAngle:2*M_PI clockwise:NO]];
        }else if (self.currentIndex == 1){
            [path appendPath:[UIBezierPath bezierPathWithArcCenter:point radius:27 startAngle:0 endAngle:2*M_PI clockwise:NO]];
        }
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    [bgView.layer setMask:shapeLayer];
    
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [bgView addSubview:imageView];
    if (self.viewType == FLGV_Type_MyPage) {
        if (self.currentIndex == 0) {
            imageView.frame = CGRectMake(75, 30+200*WIDTH/375.0, 179, 223);
            imageView.image = kImageWithName(@"bg_mb_my");
        }
    }else if (self.viewType == FLGV_Type_Contact) {
        if (self.currentIndex == 0) {
            imageView.frame = CGRectMake(WIDTH/5.0/2*3-47, 166, 187, 209);
            imageView.image = kImageWithName(@"mb_rm_01");
        }else if (self.currentIndex == 1) {
            imageView.frame = CGRectMake(WIDTH/5.0/2*5-72, 187, 143, 184);
            imageView.image = kImageWithName(@"mb_rm_02");
        }else{
            imageView.frame = CGRectMake(WIDTH/5.0/2*9-246, 176, 219, 225);
            imageView.image = kImageWithName(@"mb_rm_03");
        }
    }else{
        if (self.currentIndex == 0) {
            if(WIDTH>375){
                imageView.frame = CGRectMake(WIDTH-36-17-192, 52, 203, 192);
            }else{
                imageView.frame = CGRectMake(WIDTH-31-17-192, 52, 203, 192);
            }
            imageView.image = kImageWithName(@"dh_sy_05");
        }else  if (self.currentIndex == 1){
            imageView.frame = CGRectMake(WIDTH-80-221, HEIGHT-101-180, 221, 180);
            imageView.image = kImageWithName(@"bg_mb_index");
        }
    }
}

- (void)sureTapClick:(UITapGestureRecognizer *)tap{
    UIView * view = tap.view;
    [view removeFromSuperview];
    [view removeGestureRecognizer:tap];
    NSInteger index = 0;
    if (self.viewType == FLGV_Type_MyPage) {
        index = 0;
    }else if (self.viewType == FLGV_Type_Contact) {
        index = 2;
    }else{
        index = 1;
    }
    if (self.viewType == FLGV_Type_HomeVC) {
        if ([self.firstLaunchGuideViewDelegate respondsToSelector:@selector(mainFeistMoveMark:)]) {
            [self.firstLaunchGuideViewDelegate mainFeistMoveMark:self.currentIndex];
        }
    }
    if(self.currentIndex == index){
        if(self.viewType == FLGV_Type_MyPage) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FirstLaunchGuideViewMarkMySelf];
        }else if(self.viewType == FLGV_Type_Contact) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FirstLaunchGuideViewMarkContact];
        }else{
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FirstLaunchGuideViewMark];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self removeFromSuperview];
    }else{
        self.currentIndex++;
        [self newUserGuide];
    }
}

@end
