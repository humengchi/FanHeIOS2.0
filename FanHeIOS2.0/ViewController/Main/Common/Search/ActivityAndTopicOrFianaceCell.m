//
//  ActivityAndTopicOrFianaceCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/20.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ActivityAndTopicOrFianaceCell.h"

@implementation ActivityAndTopicOrFianaceCell
- (void)tranferActivityAndTopicOrFianaceCellModel:(SearchModel *)model searchText:(NSString*)searchText searchType:(RSearchResult)searchType{
    NSMutableArray *tagArray = [NSMutableArray arrayWithArray:model.tags];
    for(UIView *view in self.tagView.subviews){
        [view removeFromSuperview];
    }
    NSMutableArray *searchTagArray = [NSMutableArray array];
    for(NSString *tagStr in tagArray){
        NSString *searchTag = @"";
        for(NSString *str in [searchText lowercaseString].componentsSeparated){
            NSRange range = [tagStr rangeOfString:str];
            if(range.length!=0){
                searchTag = tagStr;
                break;
            }
        }
        if(searchTag.length){
            if(![searchTagArray containsObject:searchTag]){
                [searchTagArray addObject:searchTag];
            }
            continue;
        }
        for(NSString *str in [searchText uppercaseString].componentsSeparated){
            NSRange range = [tagStr rangeOfString:str];
            if(range.length!=0){
                searchTag = tagStr;
                break;
            }
        }
        if(searchTag.length){
            if(![searchTagArray containsObject:searchTag]){
                [searchTagArray addObject:searchTag];
            }
        }
    }
    if(searchTagArray.count){
        for(NSString *searchTag in searchTagArray){
            [tagArray removeObject:searchTag];
            [tagArray insertObject:searchTag atIndex:0];
        }
    }
    if (tagArray.count > 0) {
        CGFloat gY = 16;
        CGFloat gX = 16;
        self.tagLabel.text = @"大";
        for (NSInteger i = 0; i < tagArray.count; i++) {
            CGFloat wideth = [NSHelper widthOfString:tagArray[i] font:[UIFont systemFontOfSize:13] height:28]+16;
            UILabel *label = [[UILabel alloc]init];
            label.font = [UIFont systemFontOfSize:13];
            label.tag = i;
            label.userInteractionEnabled = YES;
            label.text = tagArray[i];
            if (i < searchTagArray.count) {
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
            
            [self.tagView addSubview:label];
        }
    }else{
        self.tagLabel.text = @"";
    }
    
    [self setLabelText:model.name searchText:searchText color:@"41464e" font:17 label:self.titleLabel];
    if(searchType == SearchResult_Post){
        self.readLabel.text = [NSString stringWithFormat:@"阅读 %@",model.readcount];
        self.viewLabel.text = [NSString stringWithFormat:@"评论 %@",model.reviewcount];
        self.rateLabel.hidden = YES;
        self.activityView.hidden = YES;
    }else if(searchType == SearchResult_Topic){
        self.readLabel.text = [NSString stringWithFormat:@"关注 %@",model.attentcount];
        self.viewLabel.text = [NSString stringWithFormat:@"观点 %@",model.replycount];
        self.rateLabel.text = [NSString stringWithFormat:@"评论 %@",model.reviewcount];
        self.rateLabel.hidden = NO;
        self.activityView.hidden = YES;
    }else if(searchType == SearchResult_Activity){
        self.activityView.hidden = NO;
        UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(0, 0, WIDTH-32, 17) backColor:WHITE_COLOR textColor:HEX_COLOR(@"818c9e") test:model.timestr font:14 number:1 nstextLocat:NSTextAlignmentLeft];
            [self.activityView addSubview:contentLabel];
        
        NSString *locationStr = [NSString stringWithFormat:@"%@%@", model.cityname,model.districtname];
        CGFloat locationWidth = [NSHelper widthOfString:locationStr font:FONT_SYSTEM_SIZE(14) height:17];
       
        UILabel *locationLabel = [UILabel createrLabelframe:CGRectMake(0, contentLabel.frame.size.height+contentLabel.frame.origin.y+10, locationWidth, 17) backColor:WHITE_COLOR textColor:HEX_COLOR(@"AFB6C1") test:locationStr font:14 number:1 nstextLocat:NSTextAlignmentLeft];
        [self.activityView addSubview:locationLabel];
      
        if(model.guestname.length > 0){
            //84//302//66
            CGFloat wideth = locationLabel.frame.origin.x + locationWidth;
            
            CGFloat wideth1 = [NSHelper widthOfString:model.guestname font:[UIFont systemFontOfSize:14] height:14] + 8;
            
            CGFloat wideth2 = [NSHelper widthOfString:model.price font:[UIFont systemFontOfSize:17] height:17];
     
        NSInteger guestnameLabelWideth = WIDTH - wideth - wideth2 - 48;
        if (wideth1 >  guestnameLabelWideth) {
            wideth1 = guestnameLabelWideth;
        }
            NSInteger guestnameLabelwideth1 = wideth1;
            UILabel *guestnameLabel = [[UILabel alloc]init];
            guestnameLabel.frame =CGRectMake(locationWidth + 8 ,contentLabel.frame.size.height+contentLabel.frame.origin.y+8, guestnameLabelwideth1, 20);
            guestnameLabel.textColor = HEX_COLOR(@"B0A175");
            guestnameLabel.backgroundColor = HEX_COLOR(@"FAF5E0");
            guestnameLabel.layer.masksToBounds = YES;
            guestnameLabel.layer.cornerRadius = 5;
            guestnameLabel.font = [UIFont systemFontOfSize:14];
            if (model.guestname.length > 0) {
                guestnameLabel.text = [NSString stringWithFormat:@" %@ ",model.guestname];
            }else{
                guestnameLabel.hidden = YES;
            }
            [self.activityView addSubview:guestnameLabel];
        }
        if(model.price.length > 0){
             CGFloat wideth2 = [NSHelper widthOfString:model.price font:[UIFont systemFontOfSize:17] height:17];
            UILabel *tagLabel = [UILabel createrLabelframe:CGRectMake(WIDTH - wideth2 - 32, locationLabel.frame.origin.y-2, wideth2, 17) backColor:HEX_COLOR(@"FFFFFF") textColor:[UIColor colorWithHexString:@"000000"] test:model.price font:17 number:1 nstextLocat:NSTextAlignmentRight];
            if ([model.price isEqualToString:@"免费"]) {
                tagLabel.textColor = [UIColor colorWithHexString:@"1ABC9C"];
            }else if ([model.price isEqualToString:@"已结束"]) {
                tagLabel.textColor = [UIColor colorWithHexString:@"AFB6C1"];
            }else{
                tagLabel.textColor = [UIColor colorWithHexString:@"F76B1C"];
            }
            [self.activityView addSubview:tagLabel];
        }
    }
}

+ (CGFloat)backActivityAndTopicOrFianaceCellHeigth:(SearchModel *)model searchType:(RSearchResult)searchType{
    CGFloat heigth = [NSHelper heightOfString:model.name font:[UIFont systemFontOfSize:17] width:WIDTH - 32];
    if(heigth >FONT_SYSTEM_SIZE(17).lineHeight*2){
        heigth = FONT_SYSTEM_SIZE(17).lineHeight*2+6;
    }else if(heigth>FONT_SYSTEM_SIZE(17).lineHeight){
        heigth +=6;
    }
    if(model.tags.count){
        heigth += 37;
    }
    if(searchType == SearchResult_Activity){
        heigth += 28;
    }
    return heigth+60;
}

- (void)setLabelText:(NSString*)text searchText:(NSString*)searchText color:(NSString*)color font:(CGFloat)font label:(UILabel*)label{
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:text];
    [atr setAttributes:@{NSFontAttributeName:FONT_SYSTEM_SIZE(font), NSForegroundColorAttributeName:HEX_COLOR(color)} range:NSMakeRange(0, text.length)];
    for(NSString *str in [searchText lowercaseString].componentsSeparated){
        NSRange range = [text rangeOfString:str];
        [atr setAttributes:@{NSFontAttributeName:FONT_SYSTEM_SIZE(font), NSForegroundColorAttributeName:kDefaultColor} range:range];
    }
    for(NSString *str in [searchText uppercaseString].componentsSeparated){
        NSRange range = [text rangeOfString:str];
        [atr setAttributes:@{NSFontAttributeName:FONT_SYSTEM_SIZE(font), NSForegroundColorAttributeName:kDefaultColor} range:range];
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:6];
    [atr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, text.length)];
    
    label.attributedText = atr;
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
