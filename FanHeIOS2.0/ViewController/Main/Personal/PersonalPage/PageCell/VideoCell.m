//
//  VideoCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/4.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "VideoCell.h"

@implementation VideoCell
- (void)tranferVideoTaMessageModel:(TaMessageModel *)model workArray:(NSMutableArray *)array{
    CGFloat heigth = [NSHelper heightOfString:model.remark font:[UIFont systemFontOfSize:20] width:WIDTH - 32];
    CGRect frame = self.siderLabel.frame;
    frame.size.height = heigth;
    self.siderLabel.frame = frame;

    if ([model.remark isEqualToString:@"用户还未添加个人介绍"]) {
        if (model.isMyHomePage && array.count == 0) {
             self.eaditMyInduceBtn.hidden = NO;
            self.siderLabel.text = @"你还未添加个人介绍";
            self.eaditMyInduceBtn.frame = CGRectMake(WIDTH/2 - 48, 77, 95, 28);
            [self.eaditMyInduceBtn.layer setMasksToBounds:YES];
            [self.eaditMyInduceBtn.layer setCornerRadius:5.0]; //设置矩形四个圆角半径
            [self addSubview:self.eaditMyInduceBtn];
        }else{
             self.eaditMyInduceBtn.hidden = YES;
            self.siderLabel.text = @"他还未添加个人介绍";

        }
        self.siderLabel.textColor = [UIColor colorWithHexString:@"AFB6C1"];
        self.siderLabel.font = [UIFont systemFontOfSize:17];
        self.siderLabel.textAlignment = NSTextAlignmentCenter;
    }else{
        self.eaditMyInduceBtn.hidden = YES;
        //换行
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 3;// 字体的行间距
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14],NSParagraphStyleAttributeName:paragraphStyle};
        self.siderLabel.attributedText = [[NSAttributedString alloc] initWithString:model.remark attributes:attributes];
    }
}

- (IBAction)eaditMyInduceAction:(UIButton *)sender {
    if ([self.videoDelegate respondsToSelector:@selector(eaditMyInduceAction)]) {
        [self.videoDelegate eaditMyInduceAction];
    }
}

+ (CGFloat)videoHeigthTaMessageModel:(TaMessageModel*)model{
    
    CGSize size = CGSizeMake(WIDTH - 32, 0);
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    [style setLineSpacing:3];
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:14],NSParagraphStyleAttributeName:style};
    CGSize retSize = [model.remark boundingRectWithSize:size
                                          options:\
                      NSStringDrawingTruncatesLastVisibleLine |
                      NSStringDrawingUsesLineFragmentOrigin |
                      NSStringDrawingUsesFontLeading
                                       attributes:attribute
                                          context:nil].size;
  
  
    CGFloat heigth = retSize.height+ 70;
    if ([model.remark isEqualToString:@"用户还未添加个人介绍"]) {
        if (model.isMyHomePage) {
            heigth = 134;
        }else{
             heigth = 96;
        }
    }
    return heigth;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
@end
