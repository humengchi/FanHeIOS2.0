//
//  ConnectionsCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/29.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ConnectionsCell.h"

@implementation ConnectionsCell

- (void)updateDisplay:(NSInteger)row num:(NSNumber*)num{
    NSArray *imageArray = @[@"icon_txl_follow",@"icon_txl_focus"];
    NSArray *title = @[@"我关注的",@"关注我的"];
    self.headerImage.image = [UIImage imageNamed:imageArray[row]];
    self.nameLabel.text = title[row];
    if (num.integerValue > 0 && row == 1){
        self.numLabel.text = [NSString stringWithFormat:@"%@",num];
        self.numLabel.hidden = NO;
    }else{
        self.numLabel.hidden = YES;
    }
    self.leftImage.hidden = YES;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [CALayer updateControlLayer:self.numLabel.layer radius:9 borderWidth:0 borderColor:nil];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
