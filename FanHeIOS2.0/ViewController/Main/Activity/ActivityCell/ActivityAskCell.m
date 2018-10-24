//
//  ActivityAskCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/6.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ActivityAskCell.h"

@implementation ActivityAskCell
- (void)tranferActivityAskCellModel:(UserModel *)model{
    self.useModel = model;
    self.nameLabel.userInteractionEnabled = YES;
    self.nameLabel.text = model.realname;
    self.askLabel.text = model.ask;
    self.anverAwLabel.numberOfLines = 0;
    if (model.answer.length > 0) {
        CGFloat heigth = [NSHelper heightOfString:model.answer font:[UIFont systemFontOfSize:14] width:WIDTH - 56];
        CGFloat heigth1 =  [NSHelper heightOfString:model.ask font:[UIFont systemFontOfSize:14] width:WIDTH - 32];
        self.backView.frame = CGRectMake(16, heigth1+self.askLabel.frame.origin.y+12, WIDTH - 32, heigth+47);
          CGFloat heigth3 = [NSHelper heightOfString:model.answer font:[UIFont systemFontOfSize:14] width:WIDTH - 56];
        self.anverLabel.frame = CGRectMake(12, 12, WIDTH - 24, 14);
        self.anverAwLabel.frame =  CGRectMake(12, 35, WIDTH - 48, heigth3);
    
        self.anverAwLabel.text = model.answer;
    }else{
        self.backView.hidden = YES;
    }
}
+ (CGFloat)backActivityAskCellHeigth:(UserModel *)model{
    CGFloat heigth = [NSHelper heightOfString:model.answer font:[UIFont systemFontOfSize:14] width:WIDTH - 56];
    CGFloat heigth1 =  [NSHelper heightOfString:model.ask font:[UIFont systemFontOfSize:14] width:WIDTH - 32];
    if (model.answer.length > 0) {
         return heigth+heigth1+42+12+35+28;
    }else{
        return heigth1 + 42+16;
    }
   
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)gotoHisManPage:(UITapGestureRecognizer *)sender {
    NewMyHomePageController *myHome = [[NewMyHomePageController alloc]init];
    myHome.userId = self.useModel.userId;
    [[self viewController].navigationController pushViewController:myHome animated:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
