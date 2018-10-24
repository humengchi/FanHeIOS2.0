//
//  AddFriendsViewCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/8/11.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "AddFriendsViewCell.h"

@implementation AddFriendsViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.coverImageView.layer.cornerRadius = 18;
    self.coverImageView.layer.masksToBounds = YES;
    // Initialization code
}
- (void)tranferChartModel:(ChartModel *)model groupMembers:(NSArray *)memberArray addFriends:(NSMutableArray *)addFriends{
     [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
     self.nameLabel.text = model.realname;
     self.positionLabel.text = [NSString stringWithFormat:@"%@%@",model.company,[CommonMethod paramStringIsNull:model.position]];
    NSString *useID = [NSString stringWithFormat:@"%@",model.userid];
    if (self.isRemove) {
        if ([memberArray containsObject:model.userid]) {
             self.selectBtn.selected = YES;
        }else{
            self.selectBtn.selected = NO;
        }
    }else{
        NSLog(@"%@ -- %@ --%@",memberArray,useID,addFriends);
        if ([memberArray containsObject:useID]) {
            if ([addFriends containsObject:model.userid]) {
                self.selectBtn.selected = YES;
            }else{
                [self.selectBtn setImage:[UIImage imageNamed:@"btn_xz_yxz"] forState:UIControlStateNormal];
                self.userInteractionEnabled = NO;
                
            }
        }else{
            if ([addFriends containsObject:model.userid]){
                self.selectBtn.selected = YES;
            }else{
                [self.selectBtn setImage:[UIImage imageNamed:@"btn_zy_sc_w"] forState:UIControlStateNormal];
                self.selectBtn.selected = NO;
            }
            
        }
        
 
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
