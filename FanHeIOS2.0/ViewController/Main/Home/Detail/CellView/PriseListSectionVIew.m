//
//  PriseListSectionVIew.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/3/3.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "PriseListSectionVIew.h"
#import "PraiseListViewController.h"
@implementation PriseListSectionVIew

- (void)updateDisplay:(DynamicModel*)model{
    self.model = model;
    NSLog(@"%@==== %@== ",[DataModelInstance shareInstance].userModel.userId,model.userModel.user_id);
    if ([DataModelInstance shareInstance].userModel.userId.integerValue == model.userModel.user_id.integerValue) {
        self.removeBtn.selected = NO;
    }else{
        self.removeBtn.selected = YES;
    }
    
    NSString *str = model.created_at;//时间戳
    NSTimeInterval time=[str doubleValue];//因为时差问题要加8小时 == 28800 sec
    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *currentDateStr = [dateFormatter stringFromDate: detaildate];
    
   

    self.timeLabel.text = currentDateStr;
    if (model.praiselist.count > 0) {
        CGFloat strWidth = [NSHelper widthOfString:[NSString stringWithFormat:@"%ld个人赞过", model.praiselist.count] font:FONT_SYSTEM_SIZE(14) height:50];
        UILabel *friNumLabel = [UILabel createrLabelframe:CGRectMake(WIDTH-33-strWidth, 10, strWidth, 14) backColor:WHITE_COLOR textColor:HEX_COLOR(@"AFB6C1") test:[NSString stringWithFormat:@"%@个人赞过",model.praisecount] font:14 number:1 nstextLocat:NSTextAlignmentRight];
        [self.imageView addSubview:friNumLabel];
        for (int i=0; i < model.praiselist.count; i++) {
            if(WIDTH-33-strWidth<16+27*i+18){
                break;
            }
            NSDictionary *dic = model.praiselist[i];
          
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(16+27*i, 0, 34, 34)];
            [imageView sd_setImageWithURL:[NSURL URLWithString:dic[@"image"]] placeholderImage:KHeadImageDefaultName(dic[@"realname"])];
            [self.imageView addSubview:imageView];
            [CALayer updateControlLayer:imageView.layer radius:17 borderWidth:1 borderColor:WHITE_COLOR.CGColor];
        }
       
    }else{
        self.imageView.hidden = YES;
        self.fristLine.hidden = YES;
    }
}
#pragma mark ------ 删除或者回复
- (IBAction)deletcActivityAction:(UIButton *)sender {
   [[NSNotificationCenter defaultCenter] postNotificationName:DELECTACTIVITYACTION object:nil];
}

- (IBAction)gotoPriseList:(UITapGestureRecognizer *)sender {
    PraiseListViewController *ratePraise = [[PraiseListViewController alloc]init];
    ratePraise.reviewid = self.model.dynamic_id;
    ratePraise.listType = YES;
    ratePraise.dynamicType = YES;
     [[self viewController].navigationController pushViewController:ratePraise animated:YES];
   
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
