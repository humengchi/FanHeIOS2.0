//
//  TitleViewCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/3.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "TitleViewCell.h"
#import "TagSearchController.h"
@implementation TitleViewCell
- (void)tranferTitleViewCellModel:(MyActivityModel *)model{
    self.model = model;
    self.activityLabel.text = model.name;
    self.lookLabel.text = [NSString stringWithFormat:@"%@人看过",model.readcount];
    CGFloat gY = 0;
    CGFloat gX = 0;
    self.tagLabel.userInteractionEnabled = YES;
    if (model.tags.count > 0) {
        for (NSInteger i = 0; i < model.tags.count; i++) {
            CGFloat wideth = [NSHelper widthOfString:model.tags[i] font:[UIFont systemFontOfSize:13] height:28]+16;
            UILabel *label = [[UILabel alloc]init];
            label.font = [UIFont systemFontOfSize:13];
            label.tag = i;
            label.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(searchTagFianace:)];
            [label addGestureRecognizer:tap];
            label.text = model.tags[i];
            label.textColor = [UIColor colorWithHexString:@"1ABC9C"];
            label.layer.cornerRadius = 2;
            label.layer.borderWidth = 0.5;
            label.layer.borderColor = [UIColor colorWithHexString:@"1ABC9C"].CGColor;
            label.textAlignment = NSTextAlignmentCenter;
            if (gX + 32 < WIDTH - 50) {
                label.frame = CGRectMake(gX,gY , wideth, 28);
                gX = gX + wideth + 6;
            }else{
                break;
            }
            
            [self.tagLabel addSubview:label];
        }
    }

}
- (void)searchTagFianace:(UITapGestureRecognizer *)g{
    if ([self.titleViewCellDelegate respondsToSelector:@selector(viewIsHidder)]) {
        [self.titleViewCellDelegate viewIsHidder];
    }
    TagSearchController *tag = [[TagSearchController alloc]init];
    tag.tagStr = self.model.tags[g.view.tag];
    [[self viewController].navigationController pushViewController:tag animated:YES];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
+ (CGFloat)backTitleViewCellHeigth:(MyActivityModel *)model{
    
    CGFloat heigth = [NSHelper heightOfString:model.name font:[UIFont boldSystemFontOfSize:20] width:WIDTH - 32];
    return heigth + 72;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
