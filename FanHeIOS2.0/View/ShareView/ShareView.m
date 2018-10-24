//
//  ShareView.m
//  JinMai
//
//  Created by 胡梦驰 on 16/5/13.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import "ShareView.h"

@interface ShareView ()
@property (nonatomic, weak) IBOutlet UIView *bgView;
@end

@implementation ShareView

- (void)createrShareView{
    UIView *bottenView = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, WIDTH * 0.46) backColor:@"FFFFFF"];
   
    bottenView.userInteractionEnabled = YES;
  
    UIButton *botonBtn = [NSHelper createButton:CGRectMake(0, WIDTH * 0.46 - 50,WIDTH, 50) title:@"取消" unSelectImage:nil selectImage:nil target:self selector:@selector(cancleShawerView:)];
    botonBtn.tag = 4;
    botonBtn.backgroundColor = [UIColor colorWithHexString:@"F8F8F8"];
    [botonBtn setTitle:@"取消" forState:UIControlStateNormal];
    [botonBtn setTitleColor:[UIColor colorWithHexString:@"FF666666"] forState:UIControlStateNormal];
   
    [self addSubview:bottenView];
    [bottenView addSubview:botonBtn];
    NSArray *imageArray;
    if (self.isDynamic) {
        imageArray = @[@"btn_trends_sh",@"btn_pop_weixin",@"btn_pop_pengyouquan",@"btn_pop_51jinmai",@"btn_pop_copylink"];
    }else{
        imageArray = @[@"btn_pop_weixin",@"btn_pop_pengyouquan",@"btn_pop_51jinmai",@"btn_pop_copylink"];
    }
   
//       CGFloat shareWideth = (WIDTH - 68)/4;
    CGFloat shareWideth = (WIDTH - 194)/4;
    for (NSInteger i =0 ; i < imageArray.count; i ++){
    self.shareView = [[UIView alloc]initWithFrame:CGRectMake((42+shareWideth)*i+34,0 ,shareWideth ,  WIDTH * 0.46 - 50)];
        [bottenView addSubview:self.shareView];
        self.shareView.tag = i;
        self.shareView.userInteractionEnabled = YES;
        UITapGestureRecognizer *shareTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(shareActionMake:)];
        [self.shareView addGestureRecognizer:shareTap];
        
        UIImageView *shareImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 25,shareWideth,shareWideth)];
        [self.shareView addSubview:shareImage];
        UILabel *shareLabel = [[UILabel alloc]initWithFrame:CGRectMake(-10,shareWideth + 30, self.shareView.frame.size.width+20, 14)];
        shareLabel.textAlignment = NSTextAlignmentCenter;
        shareLabel.font = [UIFont systemFontOfSize:12];
        shareLabel.textColor = [UIColor colorWithHexString:@"999999"];
        [self.shareView addSubview:shareLabel];
        if (self.isDynamic) {
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

        }else{
            switch (i){
                case 0:
                    shareImage.image = [UIImage imageNamed:imageArray[i]];
                    shareLabel.text = @"微信好友";
                    
                    break;
                case 1:
                    shareImage.image = [UIImage imageNamed:imageArray[i]];
                    shareLabel.text = @"朋友圈";
                    break;
                case 2:
                    shareImage.image = [UIImage imageNamed:imageArray[i]];
                    shareLabel.text = @"金脉好友";
                    break;
                case 3:
                    shareImage.image = [UIImage imageNamed:imageArray[i]];
                    shareLabel.text = @"复制链接";
                    break;
                    
                default:
                    break;
            }
        }
    }
    UIView *lineView = [NSHelper createrViewFrame:CGRectMake(0, WIDTH * 0.46 - 50, WIDTH, 0.5) backColor:@"d9d9d9"];
    [bottenView addSubview:lineView];

}
- (void)cancleShawerView:(UIButton *)btn
{
    _showShareViewIndex(btn.tag);
}
- (void)shareActionMake:(UITapGestureRecognizer *)g{
     _showShareViewIndex(g.view.tag);

}
@end
