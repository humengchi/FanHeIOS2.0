//
//  TagSearchCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "TagSearchCell.h"

@implementation TagSearchCell
- (void)tranferTagSearchCellModel:(MyActivityModel *)model{
    if (model.addresstype.integerValue == 1) {
        self.addImageView.hidden = YES;
    }
    NSMutableArray *tagArray = [NSMutableArray arrayWithArray:model.tags];
    [tagArray removeObject:self.strTag];
    [tagArray insertObject:self.strTag atIndex:0];
    CGFloat gY = 0;
    CGFloat gX = 16;
    if (tagArray.count > 0) {
        for (NSInteger i = 0; i < tagArray.count; i++) {
            CGFloat wideth = [NSHelper widthOfString:tagArray[i] font:[UIFont systemFontOfSize:13] height:28]+16;
            UILabel *label = [[UILabel alloc]init];
            label.font = [UIFont systemFontOfSize:13];
            label.tag = i;
            label.userInteractionEnabled = YES;
            label.text = tagArray[i];
            if (i == 0) {
                label.textColor = [UIColor colorWithHexString:@"E24943"];
                label.layer.borderColor = [UIColor colorWithHexString:@"E24943"].CGColor;
            }else{
                label.textColor = [UIColor colorWithHexString:@"1ABC9C"];
                  label.layer.borderColor = [UIColor colorWithHexString:@"1ABC9C"].CGColor;
            }
           
            label.layer.cornerRadius = 2;
            label.layer.borderWidth = 0.5;
          
            label.textAlignment = NSTextAlignmentCenter;
            if (gX + 32 < WIDTH - 50) {
                label.frame = CGRectMake(gX,gY , wideth, 21);
                gX = gX + wideth + 8;
            }else{
                break;
            }
            
            [self.tagLabel addSubview:label];
        }
    }
    
    CGFloat wideth = self.addressLabel.frame.origin.x + self.addressLabel.frame.size.width;
    CGFloat startWideth =  self.addressLabel.frame.size.width;
    
    
    CGFloat wideth1 = [NSHelper widthOfString:model.guestname font:[UIFont systemFontOfSize:14] height:14];
    wideth1 += 8;
    if (wideth1 >  (WIDTH - wideth - startWideth - 16 - 16)) {
        wideth1 = WIDTH - wideth - startWideth - 16 - 16;
    }
    CGFloat heigth = [NSHelper heightOfString:model.name font:[UIFont systemFontOfSize:17] width:WIDTH - 32];
    if (heigth > 25) {
        heigth = 36;
    }
    
//    self.guestnameLabel.frame = CGRectMake(wideth + 8, 96 +  heigth, wideth1, 20);
    self.guestnameLabel.textColor = HEX_COLOR(@"B0A175");
    self.guestnameLabel.backgroundColor = HEX_COLOR(@"FAF5E0");
    self.guestnameLabel.layer.masksToBounds = YES;
    self.guestnameLabel.layer.cornerRadius = 5;
    self.guestnameLabel.font = [UIFont systemFontOfSize:14];
    if (model.guestname.length > 0) {
        self.guestnameLabel.text = [NSString stringWithFormat:@" %@ ",model.guestname];
    }else{
        self.guestnameLabel.hidden = YES;
    }

    if ([model.price isEqualToString:@"免费"]) {
        self.startLabel.textColor = [UIColor colorWithHexString:@"1ABC9C"];
    }else if ([model.price isEqualToString:@"已结束"]) {
        self.startLabel.textColor = [UIColor colorWithHexString:@"AFB6C1"];
    }else{
        self.startLabel.textColor = [UIColor colorWithHexString:@"F76B1C"];
    }
    if (model.price.length == 0) {
        self.startLabel.hidden = YES;
    }

    self.titleLabel.text = model.name;
    self.timeLabel.text = model.timestr;
    self.addressLabel.text = [NSString stringWithFormat:@"%@%@",model.cityname,model.districtname];
    self.addImageView.hidden = YES;
}

+ (CGFloat)backTagSearchCellHeigth:(MyActivityModel *)model{
    CGFloat heigth = [NSHelper heightOfString:model.name font:[UIFont systemFontOfSize:17] width:WIDTH - 32];
    NSLog(@"%@  heigth = %f",model.name,heigth);
    if (heigth > 25) {
        heigth = 42;
    }
    return heigth + 132;
    
}

- (void)tranferTagSearchCellModelSearch:(SearchModel *)model{
    if (model.addresstype.integerValue == 1) {
        self.addImageView.hidden = YES;
    }
    NSMutableArray *tagArray = [NSMutableArray arrayWithArray:model.tags];
//    [tagArray removeObject:self.strTag];
//    [tagArray insertObject:self.strTag atIndex:0];
    CGFloat gY = 0;
    CGFloat gX = 16;
    if (tagArray.count > 0) {
        for (NSInteger i = 0; i < tagArray.count; i++) {
            CGFloat wideth = [NSHelper widthOfString:tagArray[i] font:[UIFont systemFontOfSize:13] height:28]+16;
            UILabel *label = [[UILabel alloc]init];
            label.font = [UIFont systemFontOfSize:13];
            label.tag = i;
            label.userInteractionEnabled = YES;
            label.text = tagArray[i];
            if (i == 0) {
                label.textColor = [UIColor colorWithHexString:@"E24943"];
                label.layer.borderColor = [UIColor colorWithHexString:@"E24943"].CGColor;
            }else{
                label.textColor = [UIColor colorWithHexString:@"1ABC9C"];
                label.layer.borderColor = [UIColor colorWithHexString:@"1ABC9C"].CGColor;
            }
            
            label.layer.cornerRadius = 2;
            label.layer.borderWidth = 0.5;
            
            label.textAlignment = NSTextAlignmentCenter;
            if (gX + 32 < WIDTH - 50) {
                label.frame = CGRectMake(gX,gY , wideth, 21);
                gX = gX + wideth + 8;
            }else{
                break;
            }
            
            [self.tagLabel addSubview:label];
        }
    }
    
    self.titleLabel.text = model.name;
    self.timeLabel.text = model.timestr;
    self.addressLabel.text = [NSString stringWithFormat:@"%@%@",model.cityname,model.districtname];
}

+ (CGFloat)backTagSearchCellHeigthSearch:(SearchModel *)model{
    CGFloat heigth = [NSHelper heightOfString:model.name font:[UIFont systemFontOfSize:17] width:WIDTH - 32];
    if (heigth > 25) {
        heigth = 36;
    }
    return heigth + 132;
    
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
