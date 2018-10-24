//
//  ActivityApplyCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/3.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ActivityApplyCell.h"

@implementation ActivityApplyCell
- (void)traferActivityApplyCellModel:(MyActivityModel *)model array:(NSMutableArray *)applyArray{
    self.applyManLabel.text = model.applystr;
 
    CGFloat strWidth = 120;
    if (applyArray.count) {
        for (int i=0; i < applyArray.count; i++) {
            if(WIDTH-strWidth<16+27*i+18){
                break;
            }
            UserModel *useModel = applyArray[i];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(16+27*i, 16, 34, 34)];
            [imageView sd_setImageWithURL:[NSURL URLWithString:useModel.image] placeholderImage:KHeadImageDefaultName(useModel.realname)];
            [self addSubview:imageView];
            [CALayer updateControlLayer:imageView.layer radius:17 borderWidth:1 borderColor:WHITE_COLOR.CGColor];
            if(applyArray.count>6&&i==5){
                imageView.image = kImageWithName(@"btn_hd_more");
                break;
            }
        }
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
