//
//  WorkHistoryCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/10/28.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "WorkHistoryCell.h"

@implementation WorkHistoryCell
- (void)workHistoryCellModel:(workHistryModel *)model{
    if (self.Index == 0) {
        self.topImageView.hidden = YES;
    }
    
    self.companyLabel.text = [NSString stringWithFormat:@"%@%@",model.company,model.position];
    NSString *begStr = [model.begintime stringByReplacingOccurrencesOfString:@"-" withString:@"."];
    NSString *endtimeStr;
    if (![model.endtime isEqualToString:@"至今"]) {
        endtimeStr = [model.endtime stringByReplacingOccurrencesOfString:@"-" withString:@"."];
    }else{
        endtimeStr = @"至今";
    }
    self.timeLabel.text = [NSString stringWithFormat:@"%@ - %@",begStr,endtimeStr];
//    self.timeLabel.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"icon_zy_sjx"] stretchableImageWithLeftCapWidth:5 topCapHeight:5]];
    
    CGRect frame = self.workDetailLabel.frame;
    CGFloat heigth = [NSHelper heightOfString:model.jobintro font:[UIFont systemFontOfSize:14] width:WIDTH - 86];
    
    frame.size.height = heigth;
    self.workDetailLabel.frame = frame;
    
    self.workDetailLabel.text = model.jobintro;
    if (model.jobintro.length <= 0) {
        self.leftImageView.hidden = YES;
    }
   
    if ( model.attestationlist.count> 0) {
        NSInteger index = model.attestationlist.count;
        if ( model.attestationlist.count >= 4) {
            index  = 6;
        }else{
            index =  index+1;
 
        }
        UIImageView *imageView;
        for (NSInteger i = 0; i < index; i++) {
            
            float x = 28*i;
           imageView = [[UIImageView alloc]initWithFrame:CGRectMake(x,0, 34, 34)];
            if (i == 0) {
                 imageView.image = [UIImage imageNamed:@"icon_work_rz"];
            }else if (i == 5){
                imageView.image = [UIImage imageNamed:@"icon_index_rmgd"];
            }else{
                NSMutableDictionary *dic = model.attestationlist[i-1];
                 [imageView sd_setImageWithURL:[NSURL URLWithString:dic[@"image"]] placeholderImage:KHeadImageDefaultName(dic[@"realname"])];
            }
           
            imageView.layer.cornerRadius = imageView.frame.size.width / 2.0;
            imageView.layer.masksToBounds = YES;
            [self.tagCell addSubview:imageView];
        }
        
        UILabel *acountLabel = [UILabel createLabel:CGRectMake(imageView.frame.origin.x+34+16, 10, WIDTH - imageView.frame.origin.x-34-16 , 14) font:[UIFont systemFontOfSize:14] bkColor:[UIColor clearColor] textColor:[UIColor colorWithHexString:@"AFB6C1"]];
        acountLabel.text = [NSString stringWithFormat:@"%@人为Ta认证",model.attestationtotal];
        [self.tagCell addSubview:acountLabel];
    }else{
        self.tagCell.hidden = YES;
    }
       if (self.isMainHistory) {
        self.leftImageView.hidden = YES;
        self.workDetailLabel.numberOfLines = 0;
    }
}

+ (CGFloat)workHistoryCellModel:(workHistryModel*)model{
    CGFloat heigth = [NSHelper heightOfString:model.jobintro font:[UIFont systemFontOfSize:14] width:WIDTH - 86];
    if (heigth > 25) {
        heigth = 36;
    }else{
        heigth = 16;
    }
    if (model.jobintro.length <= 0) {
        heigth = 0;
    }
    if (model.attestationlist.count > 0) {
        return heigth + 85 + 56;

    }

    return heigth + 85 ;
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
