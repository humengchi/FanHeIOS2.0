//
//  UrlShowView.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/2/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "UrlShowView.h"

@implementation UrlShowView
- (void)createrUrlView:(NSArray *)urlArray{
    for (NSInteger i = 0; i < urlArray.count; i++) {
        NSDictionary *dic = urlArray[i];
        CGFloat y = 12+(12+40)*i;
        UIView *view = [NSHelper createrViewFrame:CGRectMake(16, y, WIDTH - 32, 40) backColor:@"F8F8FA"];
        view.tag = i;
        view.userInteractionEnabled = YES;
        [self addSubview:view];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(12, 12, 16, 16)];
        [imageView sd_setImageWithURL:[NSURL URLWithString:dic[@"image"]] placeholderImage:kImageWithName(@"icon_work_company")];
        [view addSubview:imageView];
        
        UILabel *label = [UILabel createLabel:CGRectMake(34, 13, WIDTH - 96, 14) font:[UIFont systemFontOfSize:14] bkColor:[UIColor clearColor] textColor:[UIColor colorWithHexString:@"41464E"]];
        label.text = [CommonMethod paramStringIsNull:dic[@"title"]].length?dic[@"title"]:@"标题";
        [view addSubview:label];
        UIImageView *tagImageView = [[UIImageView alloc]initWithFrame:CGRectMake(view.frame.size.width - 26, 12, 14, 14)];
        tagImageView.tag = i;
        if (self.showImage) {
            tagImageView.image = self.showImage;
        }else{
            tagImageView.image = [UIImage imageNamed:@"icon_work_link"];
        }
        [view addSubview:tagImageView];
        UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(urlTapAction:)];
        [view addGestureRecognizer:g];
    }
}

- (void)urlTapAction:(UITapGestureRecognizer *)g{
    NSInteger index = g.view.tag;
    if ([self.urlShowViewDelegate respondsToSelector:@selector(gotoMakeUrl:)]) {
        [self.urlShowViewDelegate gotoMakeUrl:index];
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
