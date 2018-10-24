//
//  GooAtCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/10/28.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "GooAtCell.h"

@implementation GooAtCell
- (void)tranferGoodAt:(TaMessageModel *)model{
    for(UIView *view in self.goodAtScrollView.subviews){
        [view removeFromSuperview];
    }
    NSArray *array = model.business;
    if (model.isMyHomePage && array.count == 0) {
        UILabel *label = [UILabel createLabel:CGRectMake(0, 20,WIDTH, 17) font:[UIFont systemFontOfSize:17] bkColor:[UIColor whiteColor] textColor:[UIColor colorWithHexString:@"AFB6C1"]];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"你还未添加擅长业务";
        [self.goodAtScrollView addSubview:label];
    }else{
        CGFloat wideth = 0;
        CGFloat x = 0;
        for (NSInteger i = 0; i <array.count; i++) {
            NSString *str = [NSString stringWithFormat:@"#%@# ",array[i]];
            if (i == 0) {
                x = 26;
                wideth = [NSHelper widthOfString:str font:[UIFont systemFontOfSize:13] height:29] + 16;
            }else {
                x = 26+wideth+i*6;
                wideth = wideth + [NSHelper widthOfString:str font:[UIFont systemFontOfSize:13] height:29] + 16;
            }
            
            UILabel *label = [UILabel createLabel:CGRectMake(x, 20, [NSHelper widthOfString:str font:[UIFont systemFontOfSize:13] height:13] + 16, 29) font:[UIFont systemFontOfSize:13] bkColor:[UIColor whiteColor] textColor:[UIColor colorWithHexString:@"1ABC9C"]];
            label.tag = i;
            label.text = str;
            label.clipsToBounds = YES;
            // 设置圆角
            label.layer.cornerRadius = 5;
            label.userInteractionEnabled = YES;
            label.textAlignment = NSTextAlignmentCenter;
            label.layer.borderColor = [UIColor colorWithHexString:@"1ABC9C"].CGColor;
            label.layer.borderWidth = 0.5;
            [self.goodAtScrollView addSubview:label];
            UITapGestureRecognizer *goodAtTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(searchGoodAt:)];
            [label addGestureRecognizer:goodAtTap];
            
            if (26+wideth+i*6+26  > WIDTH ) {
                self.goodAtScrollView.contentSize = CGSizeMake(26+wideth+i*6+26, 0);
            }
        }
    }
}
- (void)searchGoodAt:(UITapGestureRecognizer *)g{
    if([self.gooAtCellDelegate respondsToSelector:@selector(searchResultGoodAt:)]){
        [self.gooAtCellDelegate searchResultGoodAt:g.view.tag];
    }
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
