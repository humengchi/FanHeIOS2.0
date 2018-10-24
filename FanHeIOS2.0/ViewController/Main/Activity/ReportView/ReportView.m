//
//  ReportView.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/5/4.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ReportView.h"
#import "SubjectDetailViewController.h"
#import "SubjectMoreViewCtr.h"
@implementation ReportView
- (void)createrReport:(NSMutableArray *)array isAllShow:(BOOL)isAllShow{
    self.reportArray = array;
    self.isMore = isAllShow;
    self.backgroundColor = [UIColor whiteColor];
    NSInteger count = array.count;
    if (isAllShow) {
        
    }else{
        if (array.count > 8) {
            count = 8;
        }else{
            count = array.count;
        }
    }
    for (NSInteger i = 0; i < count; i++) {
        SubjectlistModel *model = array[i];
        NSInteger col = i%4;
        NSInteger cow = i/4;
        UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(col*((WIDTH- 32)/4.0)+ 16, cow*102 + 16, (WIDTH - 32)/4.0, 102)];
           [self addSubview:backView];
        UIImageView *coveImageView = [[UIImageView alloc]initWithFrame:CGRectMake(backView.frame.size.width/2.0 - 30, 0, 60, 60)];
        coveImageView.contentMode = UIViewContentModeScaleAspectFill;
        //设置圆角
        coveImageView.layer.cornerRadius = coveImageView.frame.size.width / 2;
        //将多余的部分切掉
        coveImageView.layer.masksToBounds = YES;
        [backView addSubview:coveImageView];
        CGFloat titleLabelWideth = backView.frame.size.width;
        UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(8, 72, titleLabelWideth - 16 , 14) backColor:[UIColor whiteColor] textColor:[UIColor colorWithHexString:@"41464E"] test:model.name font:14.0 number:1 nstextLocat:NSTextAlignmentCenter];
        [backView addSubview:titleLabel];
        if (isAllShow) {
             [coveImageView sd_setImageWithURL:[NSURL URLWithString:model.ios_icon2x] placeholderImage:KEqualWHImageDefault];
        }else{
            if (array.count > 8) {
                if (i == 7) {
                    [coveImageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"btn_hd_more"]];
                    titleLabel.text = @"更多";
                }else{
                    [coveImageView sd_setImageWithURL:[NSURL URLWithString:model.ios_icon2x] placeholderImage:KEqualWHImageDefault];
                }
            }else{
                [coveImageView sd_setImageWithURL:[NSURL URLWithString:model.ios_icon2x] placeholderImage:KEqualWHImageDefault]; 
            }
        }
       
        backView.tag = i;
        UITapGestureRecognizer *tapReport = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gotoDetailReport:)];
        [backView addGestureRecognizer:tapReport];
    }
}
- (void)gotoDetailReport:(UITapGestureRecognizer *)tap{
    NSInteger index = tap.view.tag;
    SubjectlistModel *model = self.reportArray[index];
    if (self.isMore) {
        SubjectDetailViewController *activity = [[SubjectDetailViewController alloc]init];
        activity.model = model;
        [[self viewController].navigationController pushViewController:activity animated:YES];
    }else{
        if (self.reportArray.count > 8) {
            if (index < 7) {
                SubjectDetailViewController *activity = [[SubjectDetailViewController alloc]init];
                activity.model = model;
                [[self viewController].navigationController pushViewController:activity animated:YES];
            }else{
                SubjectMoreViewCtr *activity = [[SubjectMoreViewCtr alloc]init];
                activity.array = self.reportArray;
                [[self viewController].navigationController pushViewController:activity animated:YES];
            }
            
        }else{
            SubjectDetailViewController *activity = [[SubjectDetailViewController alloc]init];
            activity.model = model;
            [[self viewController].navigationController pushViewController:activity animated:YES];
        }
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
