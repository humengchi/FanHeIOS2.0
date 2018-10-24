//
//  RatePariseCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/19.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "RatePariseCell.h"

@implementation RatePariseCell
- (void)createrRateModel{
    NSString *positStr = @"ds";
    NSString *nameStr = @"任浩";

    
    CGFloat heigth = 16;
    CGFloat wideth = [NSHelper widthOfString:nameStr font:[UIFont systemFontOfSize:12] height:12];
    if (positStr.length > 0) {
        self.positionLabel.frame = CGRectMake(69, heigth, WIDTH - 69 - 16, 14);
      
        self.nameLabel.frame = CGRectMake(69, 40, wideth, 14);
        self.interViewImageView.frame = CGRectMake(69+wideth +3 , 40, 31, 11);
    }else{
        self.positionLabel.hidden = YES;
         self.nameLabel.frame = CGRectMake(69, 29, wideth, 14);
          self.interViewImageView.frame = CGRectMake(69+wideth + 3, 29, 31, 11);
        
    }
    self.nameLabel.text = nameStr;
   
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
