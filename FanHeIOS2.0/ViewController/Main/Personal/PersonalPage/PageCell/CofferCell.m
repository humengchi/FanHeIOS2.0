//
//  CofferCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/4.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "CofferCell.h"

@implementation CofferCell

- (void)tranferModeVale:(NSInteger)index cofferModel:(CofferModel *)coffModel peopleModel:(PeopleModel *)peopleModel isMyHomePage:(BOOL)isMyHomePage taModel:(TaMessageModel *)model{
  
    NSString *cofferStr;
    NSString *peopoleStr;
    if(index == 3){
        self.markImageView.image = [UIImage imageNamed:@"icon_zy_rm"];
    }else{
        self.markImageView.image = [UIImage imageNamed:@"icon_zy_coffee"];
    }
    cofferStr = [NSString stringWithFormat:@"%ld个用户领取",(long)coffModel.count.integerValue];
    if(isMyHomePage){
        peopoleStr = [NSString stringWithFormat:@"%ld个好友",(long)peopleModel.count.integerValue];
    }else{
        peopoleStr = [NSString stringWithFormat:@"%ld个共同好友",(long)peopleModel.count.integerValue];
    }
    if (!model.isMyHomePage) {
        if (index == 3) {
            self.attionNumberLabel.text = [NSString stringWithFormat:@"%ld人关注Ta",model.attentionhenum.integerValue];
        }else{
            self.attionNumberLabel.hidden = YES;
        }
    }else{
        self.attionNumberLabel.hidden = YES; 
    }
    
    if(self.useCountLabel == nil){
        self.useCountLabel = [UILabel createLabel:CGRectMake(141, 65, 140, 14) font:[UIFont systemFontOfSize:14] bkColor:[UIColor clearColor] textColor:[UIColor colorWithHexString:@"FFAFB6C1"]];
        self.useCountLabel.adjustsFontSizeToFitWidth = YES;
        self.useCountLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.useCountLabel];
    }
    self.leftRigthImageView.frame = CGRectMake(WIDTH - 8 - 16, 65, 8, 15);
    UIView *lineView = [NSHelper createrViewFrame:CGRectMake(0,124 - 0.5, WIDTH, 0.5) backColor:@"d9d9d9"];
    [self addSubview:lineView];
    if (index == 3 && peopleModel.count.integerValue == 0 ) {
          self.useCountLabel.frame = CGRectMake(10, 50, WIDTH - 20, 17);
        self.useCountLabel.font = [UIFont systemFontOfSize:17];
        self.useCountLabel.textAlignment = NSTextAlignmentCenter;
        if(isMyHomePage){
            peopoleStr = @"你还没有好友";
        }else{
            peopoleStr = @"暂无共同好友";
        }
        self.leftRigthImageView.hidden = YES;
    lineView.frame = CGRectMake(0,96 - 0.5, WIDTH, 0.5);
           self.leftRigthImageView.frame = CGRectMake(WIDTH - 8 - 16, 51, 8, 15);
    }else if(index == 3 && peopleModel.count.integerValue != 0){
        NSArray *imgArray = peopleModel.photo;
        NSInteger num = imgArray.count>3?3:imgArray.count;
        CGFloat offset = 16+36*num+(num>0?15:0);
        self.useCountLabel.frame = CGRectMake(offset, 65, WIDTH-35-offset, 14);
    }
    if (index == 4 && coffModel.count.integerValue == 0) {
        self.leftRigthImageView.hidden = YES;
        lineView.frame = CGRectMake(0,96 - 0.5, WIDTH, 0.5);
        cofferStr = @"还没有用户领取你的人脉咖啡";
        self.useCountLabel.frame = CGRectMake(10, 50, WIDTH - 20, 17);
        self.useCountLabel.font = [UIFont systemFontOfSize:17];
        self.leftRigthImageView.frame = CGRectMake(WIDTH - 8 - 16, 51, 8, 15);
        self.useCountLabel.textAlignment = NSTextAlignmentCenter;

    }else if(index == 4 && coffModel.count.integerValue != 0){
        NSArray *imgArray = coffModel.photo;
        NSInteger num = imgArray.count>3?3:imgArray.count;
        CGFloat offset = 16+36*num+(num>0?15:0);
        self.useCountLabel.frame = CGRectMake(offset, 65, WIDTH-35-offset, 14);
    }

    NSArray *array;
    if(isMyHomePage){
        array = @[@"我的人脉",@"人脉咖啡"];
    }else{
        array = @[@"Ta的人脉",@"人脉咖啡"];
    }
    if (index == 4) {
        
    }
    self.titleLabel.text = array[index - 3];
    
    [CALayer updateControlLayer:self.firstImageView.layer radius:22 borderWidth:1 borderColor:WHITE_COLOR.CGColor];
    [CALayer updateControlLayer:self.secendImageView.layer radius:22 borderWidth:1 borderColor:WHITE_COLOR.CGColor];
    [CALayer updateControlLayer:self.threeImageView.layer radius:22 borderWidth:1 borderColor:WHITE_COLOR.CGColor];
    self.firstImageView.backgroundColor = [UIColor clearColor];
    self.secendImageView.backgroundColor = [UIColor clearColor];
    self.threeImageView.backgroundColor = [UIColor clearColor];
    
    NSArray *imgArray;
    if (index == 4) {
        imgArray = coffModel.photo;
        self.useCountLabel.text = cofferStr;

    }else if (index == 3) {
        imgArray = peopleModel.photo;
        self.useCountLabel.text = peopoleStr;

    }
    for(int i=0; i < imgArray.count; i++){
        if(i == 3){
            break;
        }
        NSDictionary *dict = imgArray[i];
        UIImageView *imageView = [self.contentView viewWithTag:301+i];
        imageView.hidden = NO;
        [imageView sd_setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"image"]] placeholderImage:KHeadImageDefaultName(dict[@"realname"])];
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
