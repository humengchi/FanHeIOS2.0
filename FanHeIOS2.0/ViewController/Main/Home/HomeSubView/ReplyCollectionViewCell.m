//
//  ReplyCollectionViewCell.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ReplyCollectionViewCell.h"

@interface ReplyCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;


@end

@implementation ReplyCollectionViewCell

- (void)updateDisplay:(NSDictionary *)dict{
    self.nameLabel.text = dict[@"realname"];
    self.msgLabel.text = dict[@"revert"];
    self.timeLabel.text = dict[@"time"];
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:dict[@"image"]] placeholderImage:KHeadImageDefaultName(self.nameLabel.text)];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [CALayer updateControlLayer:self.headerImageView.layer radius:17 borderWidth:0 borderColor:nil
     ];
    // Initialization code
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        //initialize code...
    }
    return self;
}

@end
