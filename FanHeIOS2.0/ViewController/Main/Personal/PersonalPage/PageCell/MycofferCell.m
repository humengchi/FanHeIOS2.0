//
//  MycofferCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/10.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "MycofferCell.h"

@implementation MycofferCell
- (void)myRelationFriendContactsModel:(ContactsModel*)model{
    self.headerImageView.layer.masksToBounds = YES; //没这句话它圆不起来
    self.headerImageView.layer.cornerRadius = 22; //设置图片圆角的尺度
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
    NSMutableArray *array = [NSMutableArray array];
    if([[CommonMethod paramStringIsNull:model.realname] length]){
        [array addObject:model.realname];
    }
    self.nameLabel.text = [array componentsJoinedByString:@"｜"];

    self.describeLabel.text = [NSString stringWithFormat:@"%@%@",model.company,model.position];
    if(self.describeLabel.text.length==0){
        self.describeLabel.text = @"公司职位";
    }
}

+ (CGFloat)tableFrameBackCellHeigthContactsModel:(ContactsModel*)model{
    CGFloat heigth = [NSHelper heightOfString:[NSString stringWithFormat:@"%@%@",model.company,model.position] font:FONT_SYSTEM_SIZE(14) width:WIDTH-16-69];
    return (45+heigth);
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
