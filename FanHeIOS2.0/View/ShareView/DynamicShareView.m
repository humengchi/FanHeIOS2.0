//
//  DynamicShareView.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/3/3.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "DynamicShareView.h"

@interface DynamicShareView ()

@property (nonatomic, strong) UIView *bottenView;
@property (nonatomic, strong) UIView *coverView;

@end

@implementation DynamicShareView

- (id)initWithFrame:(CGRect)frame{
    if(self=[super initWithFrame:frame]){
        self.coverView = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, HEIGHT) backColor:@"41464E"];
        self.coverView.backgroundColor = [BLACK_COLOR colorWithAlphaComponent:0];
        [self addSubview:self.coverView];
        [CommonMethod viewAddGuestureRecognizer:self.coverView tapsNumber:1 withTarget:self withSEL:@selector(cancleShawerView)];
        
        self.bottenView = [NSHelper createrViewFrame:CGRectMake(0, HEIGHT, WIDTH, 167) backColor:@"FFFFFF"];
        [self addSubview:self.bottenView];
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 117)];
        scrollView.contentSize = CGSizeMake(470, 117);
        scrollView.showsHorizontalScrollIndicator = NO;
        [self.bottenView addSubview:scrollView];
        
        UIButton *botonBtn = [NSHelper createButton:CGRectMake(0, 117, WIDTH, 50) title:@"取消" unSelectImage:nil selectImage:nil target:self selector:@selector(cancleShawerView)];
        botonBtn.tag = 4;
        botonBtn.backgroundColor = [UIColor colorWithHexString:@"F8F8F8"];
        [botonBtn setTitle:@"取消" forState:UIControlStateNormal];
        [botonBtn setTitleColor:[UIColor colorWithHexString:@"FF666666"] forState:UIControlStateNormal];
        [self.bottenView addSubview:botonBtn];
        
        NSArray *imageArray = @[@"btn_trends_sh",@"btn_pop_weixin",@"btn_pop_pengyouquan",@"btn_pop_51jinmai",@"btn_pop_copylink"];
        
        CGFloat shareWideth = 45;
        
        for (NSInteger i =0 ; i < imageArray.count; i ++){
            UIView *btnView = [[UIView alloc]initWithFrame:CGRectMake((36+shareWideth)*i+25, 0, shareWideth, 117)];
            [scrollView addSubview:btnView];
            btnView.tag = i;
            btnView.userInteractionEnabled = YES;
            
            UITapGestureRecognizer *shareTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(shareActionMake:)];
            [btnView addGestureRecognizer:shareTap];
            
            UIImageView *shareImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 24, shareWideth, shareWideth)];
            [btnView addSubview:shareImage];
            
            UILabel *shareLabel = [[UILabel alloc]initWithFrame:CGRectMake(-5, 74, shareWideth+10, 14)];
            shareLabel.textAlignment = NSTextAlignmentCenter;
            shareLabel.font = [UIFont systemFontOfSize:12];
            shareLabel.textColor = [UIColor colorWithHexString:@"999999"];
            [btnView addSubview:shareLabel];
            switch (i){
                case 0:
                    shareImage.image = [UIImage imageNamed:imageArray[i]];
                    shareLabel.text = @"金脉动态";
                    break;
                case 1:
                    shareImage.image = [UIImage imageNamed:imageArray[i]];
                    shareLabel.text = @"微信好友";
                    break;
                case 2:
                    shareImage.image = [UIImage imageNamed:imageArray[i]];
                    shareLabel.text = @"朋友圈";
                    break;
                case 3:
                    shareImage.image = [UIImage imageNamed:imageArray[i]];
                    shareLabel.text = @"金脉好友";
                    break;
                case 4:
                    shareImage.image = [UIImage imageNamed:imageArray[i]];
                    shareLabel.text = @"复制链接";
                    break;
                    
                default:
                    break;

            }
        }
        UIView *lineView = [NSHelper createrViewFrame:CGRectMake(0, 117, WIDTH, 0.5) backColor:@"d9d9d9"];
        [self.bottenView addSubview:lineView];
    }
    return self;
}

- (void)cancleShawerView{
    [self showOrHideView:NO];
}

- (void)shareActionMake:(UITapGestureRecognizer *)g{
    _dynamicShareViewIndex(g.view.tag);
    [self showOrHideView:NO];
}

- (void)showOrHideView:(BOOL)show{
    if(show){
        [UIView animateWithDuration:0.3 animations:^{
            self.bottenView.frame = CGRectMake(0, HEIGHT-167, WIDTH, 167);
            self.coverView.backgroundColor = [BLACK_COLOR colorWithAlphaComponent:.6];
        } completion:^(BOOL finished) {
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            self.bottenView.frame = CGRectMake(0, HEIGHT, WIDTH, 167);
            self.coverView.backgroundColor = [BLACK_COLOR colorWithAlphaComponent:0];
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

@end
