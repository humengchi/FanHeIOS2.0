//
//  DynamicTranferView.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/3/3.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "DynamicTranferView.h"

@implementation DynamicTranferView
- (void)tranferDynamicTranferViewimageUrl:(NSString *)url count:(NSString *)count{
    //icon_dtfx_hd 活动
    //icon_dtfx_ht 话题
    //icon_dtfx_wz 资讯
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"icon_dtfx_hd"]];
    CGFloat heigth = [NSHelper heightOfString:count font:[UIFont systemFontOfSize:14] width:WIDTH - 95 - 37];
    if (heigth > 20) {
        self.oneLabel.text = count;
        self.twoLabe.hidden = YES;
    }else{
        self.twoLabe.text = count;
        self.oneLabel.hidden = YES;
    }
    self.twoLabe.text = @"Only override drawRect: if you perform custom drawing.";
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
