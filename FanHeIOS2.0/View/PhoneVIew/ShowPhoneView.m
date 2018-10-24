//
//  ShowPhoneView.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/10/31.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ShowPhoneView.h"

@implementation ShowPhoneView
- (void)createrPhoneView{
    if (self.canviewphone.integerValue == 0) {
        self.backgroundColor = [UIColor whiteColor];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(WIDTH/2.0 - 17, 24, 34, 34)];
        imageView.image = [UIImage imageNamed:@"icon_contact_closed"];
        [self addSubview:imageView];
        UILabel *titleLabel = [UILabel createLabel:CGRectMake(0, 67, WIDTH, 14) font:[UIFont systemFontOfSize:14] bkColor:[UIColor clearColor] textColor:[UIColor colorWithHexString:@"AFB6C1"]];
         titleLabel.text = @"对方开启了隐私保护";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        UILabel *titleLabel1 = [UILabel createLabel:CGRectMake(0, 88, WIDTH, 14) font:[UIFont systemFontOfSize:14] bkColor:[UIColor clearColor] textColor:[UIColor colorWithHexString:@"AFB6C1"]];
        titleLabel1.text = @"你无法查看Ta的联系方式";
        titleLabel1.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel1];
        
        UIButton *btn = [NSHelper createButton:CGRectMake(0,  self.frame.size.height - 50, WIDTH, 50) title:@"取消" unSelectImage:nil selectImage:nil target:self selector:@selector(cancleBtn)];
        btn.backgroundColor = [UIColor colorWithHexString:@"F8F8F8"];
        [btn setTitleColor:[UIColor colorWithHexString:@"666666"] forState:UIControlStateNormal];
        [self addSubview:btn];
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 0.5)];
        lineLabel.backgroundColor = kCellLineColor;
        [btn addSubview:lineLabel];
      
    }else{
        CGFloat swepHeigth = 34;
        NSArray *array = @[@"手机",@"邮箱",@"微信"];
    
        UIView *showPhoneView = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, self.frame.size.height) backColor:@"FFFFFF"];
        [self addSubview:showPhoneView];
        
        for (NSInteger i = 0; i < array.count; i++) {
            UILabel *label = [UILabel createLabel:CGRectMake(16, 26+(14+18)*i, 54, 14) font:[UIFont systemFontOfSize:14] bkColor:[UIColor clearColor] textColor:[UIColor colorWithHexString:@"AFB6C1"]];
            label.text = array[i];
            label.textAlignment = NSTextAlignmentCenter;
            [showPhoneView addSubview:label];
            
            UILabel *textLabel = [UILabel createLabel:CGRectMake(78, 26+(14+18)*i, WIDTH - 78 - 16, 14) font:[UIFont systemFontOfSize:14] bkColor:[UIColor clearColor] textColor:[UIColor colorWithHexString:@"3498DB"]];
                if (i == 0) {
                    textLabel.text = self.phoneNumbStr;
                }else if (i == 1){
                    textLabel.text = self.emailStr;
                }else{
                    textLabel.text = self.weixinNumberStr;
                }
            
            self.userInteractionEnabled = YES;
            showPhoneView.userInteractionEnabled = YES;
            textLabel.userInteractionEnabled = YES;
            UITapGestureRecognizer *copyTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(copyText:)];
            [textLabel addGestureRecognizer:copyTap];
            
            textLabel.tag = i;
            [showPhoneView addSubview:textLabel];
        }
        
        
        UIButton *btn = [NSHelper createButton:CGRectMake(0,  self.frame.size.height - 50, WIDTH, 50) title:@"取消" unSelectImage:nil selectImage:nil target:self selector:@selector(cancleBtn)];
        btn.backgroundColor = [UIColor colorWithHexString:@"F8F8F8"];
        [btn setTitleColor:[UIColor colorWithHexString:@"666666"] forState:UIControlStateNormal];
        [showPhoneView addSubview:btn];
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 0.5)];
        lineLabel.backgroundColor = kCellLineColor;
        [btn addSubview:lineLabel];
    }
    
}
- (void)copyText:(UITapGestureRecognizer *)g{
    NSInteger index = g.view.tag;
    _showPhoneViewIndex(index);

}
- (void)cancleBtn{
     _showPhoneViewIndex(3);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
