//
//  MyGetCoffeeTableViewCell.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/26.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "MyGetCoffeeTableViewCell.h"

@interface MyGetCoffeeTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *zfImageView;
@property (weak, nonatomic) IBOutlet UIImageView *vipImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *statueLabel;
@property (weak, nonatomic) IBOutlet UIImageView *redIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *statueLabel1;

@end

@implementation MyGetCoffeeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [CALayer updateControlLayer:self.headerImageView.layer radius:22 borderWidth:0 borderColor:nil];
    [CALayer updateControlLayer:self.statueLabel1.layer radius:2 borderWidth:0 borderColor:nil];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)updateDisplay:(MyGetCoffeeModel*)model isMyGetCoffee:(BOOL)isMyGetCoffee{
    self.vipImageView.hidden = model.usertype.integerValue != 9;
    self.zfImageView.hidden = model.othericon.integerValue != 1;
    self.companyLabel.text = [NSString stringWithFormat:@"%@%@", model.company, model.position];
    self.nameLabel.text = model.realname;
    if(model.revert.length){
        self.timeLabel.text = [NSDate stringFromDate:[NSDate dateFromString:model.reverttime format:kTimeFormat] format:kTimeFormat];
    }else{
        self.timeLabel.text = [NSDate stringFromDate:[NSDate dateFromString:model.taketime format:kTimeFormat] format:kTimeFormat];
    }
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
    self.redIconImageView.hidden = model.type.integerValue != 1;
    if(isMyGetCoffee){
        if(model.revert.length){
            self.statueLabel.text = @"回复了我";
        }else{
            self.statueLabel.text = @"领取了Ta的咖啡";
        }
        if(model.exchange.integerValue==1){
            self.statueLabel1.text = @"已兑换";
            self.statueLabel1.backgroundColor = HEX_COLOR(@"E6E8EB");
            self.statueLabel1.textColor = HEX_COLOR(@"AFB6C1");
        }else{
            self.statueLabel1.text = @"可兑换";
            self.statueLabel1.backgroundColor = HEX_COLOR(@"1ABC9C");
            self.statueLabel1.textColor = WHITE_COLOR;
        }
    }else{
        self.statueLabel.text = @"";
        if(model.revert.length){
            self.statueLabel1.text = @"已回复";
            self.statueLabel1.backgroundColor = HEX_COLOR(@"E6E8EB");
            self.statueLabel1.textColor = HEX_COLOR(@"AFB6C1");
        }else{
            self.statueLabel1.text = @"未回复";
            self.statueLabel1.backgroundColor = HEX_COLOR(@"E24943");
            self.statueLabel1.textColor = WHITE_COLOR;
        }
    }
}

@end
