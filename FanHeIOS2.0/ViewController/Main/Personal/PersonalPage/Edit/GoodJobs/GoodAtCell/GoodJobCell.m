
//
//  GoodJobCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/11/3.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "GoodJobCell.h"

@implementation GoodJobCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)goodAtlokeJob:(SubjectModel *)model row:(NSUInteger )index section:(NSInteger)section select:(BOOL)select isSearch:(NSString *)isSearch{
    if (isSearch.length > 0) {
    if ([model.business rangeOfString:isSearch].location != NSNotFound ) {
        NSInteger index = [model.business rangeOfString:isSearch].location;
        NSLog(@" index ==   %ld",index);
        NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:model.business];
        [AttributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"E24943"] range:NSMakeRange(index, isSearch.length)];
        self.nameLabel.attributedText = AttributedStr;}
    }else{
         self.nameLabel.textColor = [UIColor colorWithHexString:@"41464E"];
         self.nameLabel.text = model.business;
    }
   
    if (select == YES) {
        self.selectBtn.selected = YES;
        self.nameLabel.textColor = [UIColor colorWithHexString:@"1ABC9C"];
    }else{
          self.selectBtn.selected = NO;
    }
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
