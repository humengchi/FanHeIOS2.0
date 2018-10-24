//
//  DynamicNotificationCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/3/3.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "DynamicNotificationCell.h"

@implementation DynamicNotificationCell
- (void)tranferDynamicNotificationCellModel:(DynamicDetailModel *)model{
    self.headerImageView.tag = self.
    self.headerImageView.layer.masksToBounds = YES;
    self.headerImageView.layer.cornerRadius = self.headerImageView.frame.size.width/2.0;
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
    self.nameLabel.text = model.realname;
    self.countLabel.text = model.content;
    self.timeLabel.text = model.created_at;
       self.vetryImageView.hidden = model.usertype.integerValue != 9;
    if (model.rightimage.length > 0) {
        [self.leftImage sd_setImageWithURL:[NSURL URLWithString:model.rightimage] placeholderImage:KSquareImageDefault completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *newImage;
                CGFloat width = MIN(image.size.width, image.size.height);
                newImage = [image scaleToSquareSize:width];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.leftImage.image = newImage;
                });
            });
        }];
        self.sideLabel.hidden = YES;
    }else{
        self.sideLabel.text = [model.rightcontent filterHTML];
        self.leftImage.hidden = YES;
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
