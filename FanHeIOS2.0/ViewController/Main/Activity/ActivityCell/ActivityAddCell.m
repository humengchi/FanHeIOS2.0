//
//  ActivityAddCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/3.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ActivityAddCell.h"

@implementation ActivityAddCell
- (void)tranferActivityAddCellModel:(MyActivityModel *)model useModel:(UserModel *)usemodel{
    self.model = model;
    self.useModel = usemodel;
    self.coveImageView.layer.masksToBounds = YES;
    self.coveImageView.layer.cornerRadius = self.coveImageView.frame.size.width/2.0;
    self.coveImageView.userInteractionEnabled = YES;
    self.phoneImageView.userInteractionEnabled = YES;
    self.activityAddLabel.text = [NSString stringWithFormat:@"%@%@%@",model.cityname,model.districtname,model.address];
    self.timeLabel.text = model.timestr;
       CGFloat gX = 0;
    if (model.tickets.count > 0) {
        for (NSInteger i = 0; i < model.tickets.count; i++) {
            
             NSString *str = [NSString stringWithFormat:@"%@",model.tickets[i]];
            if ([str isEqualToString:@"0"]) {
                str =  @"免费";
            }
           
            CGFloat wideth = [NSHelper widthOfString:str font:[UIFont systemFontOfSize:14] height:14];
            UILabel *label = [[UILabel alloc]init];
            label.font = [UIFont systemFontOfSize:14];
            label.text = str;
            label.textColor = [UIColor colorWithHexString:@"818C9E"];
            label.textAlignment = NSTextAlignmentCenter;
            if (gX + 32 < WIDTH - 50) {
                label.frame = CGRectMake(gX, 0 , wideth, 14);
                gX = gX + wideth + 8;
            }else{
                break;
            }
            
            [self.costLabel addSubview:label];
        }
    }
    [self.coveImageView sd_setImageWithURL:[NSURL URLWithString:usemodel.image] placeholderImage:KHeadImageDefaultName(usemodel.realname)];
    if (usemodel.usertype.integerValue != 9) {
        self.vetryImageView.hidden = YES;
    }
    self.compayLabel.text = [NSString stringWithFormat:@"%@%@",usemodel.company,usemodel.position];
    self.nameLabel.text = [NSString stringWithFormat:@"%@",usemodel.realname];
    if (usemodel.phone.length <= 0) {
        self.phoneImageView.hidden = YES;
    }
  

}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)gotoHisManPage:(UITapGestureRecognizer *)sender {
    if (self.useModel.userId.integerValue > 0) {
        NewMyHomePageController *myHome = [[NewMyHomePageController alloc]init];
        myHome.userId = self.useModel.userId;
        [[self viewController].navigationController pushViewController:myHome animated:YES];
    }
}
- (IBAction)gotoTalkPhone:(UITapGestureRecognizer *)sender {
    
    NSString *str = [NSString stringWithFormat:@"tel:%@",self.useModel.phone];
  NSString *telStr = [str stringByReplacingOccurrencesOfString:@"#" withString:@","];
    UIWebView *callWebView = [[UIWebView alloc]init];
    [callWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:telStr]]];
    [self addSubview:callWebView];//也可以不加到页面上
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
