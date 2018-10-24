//
//  TicketDetailCell.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/6/13.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "TicketDetailCell.h"

@interface TicketDetailCell ()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *ordernumLabel;
@property (nonatomic, weak) IBOutlet UILabel *priceLabel;
@property (nonatomic, weak) IBOutlet UILabel *personLabel;

@end

@implementation TicketDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateDisplay:(TicketPersonInfoModel*)model{
    self.nameLabel.text = model.ticketname;
    if(model.dcnum && model.dcnum.length){
        self.ordernumLabel.text = [NSString stringWithFormat:@"电子券：%@", model.dcnum];
    }else{
        self.ordernumLabel.text = @"";
    }
    if(model.price.floatValue){
        self.priceLabel.text = [NSString stringWithFormat:@"￥%@元/人", model.price];
    }else{
        self.priceLabel.text = @"免费";
    }
    self.personLabel.text = [NSString stringWithFormat:@"参会者：%@（%@）", model.name, model.phone];
}

@end
