//
//  TicketListCell.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/6/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "TicketListCell.h"

@interface TicketListCell ()
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView2;
@property (weak, nonatomic) IBOutlet UIImageView *approvedImageView;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@property (weak, nonatomic) IBOutlet UILabel *ticketNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ticketTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *ticketNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *ticketInfoLabel;

@end

@implementation TicketListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateDisplay:(TicketModel*)model isSelected:(BOOL)isSelected{
    if(isSelected){
        self.bgImageView1.image = kImageWithName(@"bg_ticket_choosed_1");
        self.bgImageView2.image = kImageWithName(@"bg_ticket_choosed_2");
        self.selectedImageView.image = kImageWithName(@"icon_checkbox_checked");
    }else{
        self.bgImageView1.image = kImageWithName(@"bg_ticket_choose_1");
        self.bgImageView2.image = kImageWithName(@"bg_ticket_choose_2");
        self.selectedImageView.image = kImageWithName(@"icon_xz_wx");
    }
    self.approvedImageView.hidden = model.needcheck.integerValue==0;
    if(model.remainnum.integerValue){
        self.approvedImageView.image = kImageWithName(@"icon_ticket_sh");
        self.ticketNameLabel.textColor = HEX_COLOR(@"41464E");
        self.ticketNumLabel.textColor = HEX_COLOR(@"1ABC9C");
        self.ticketTypeLabel.textColor = HEX_COLOR(@"818C9E");
        if([CommonMethod paramStringIsNull:model.remark].length){
            self.ticketInfoLabel.textColor = HEX_COLOR(@"818C9E");
        }else{
            self.ticketInfoLabel.textColor = HEX_COLOR(@"E6E8EB");
        }
    }else{
        self.approvedImageView.image = kImageWithName(@"icon_noticket_sh");
        self.ticketNameLabel.textColor = HEX_COLOR(@"E6E8EB");
        self.ticketNumLabel.textColor = HEX_COLOR(@"E6E8EB");
        self.ticketTypeLabel.textColor = HEX_COLOR(@"E6E8EB");
        self.ticketInfoLabel.textColor = HEX_COLOR(@"E6E8EB");
    }
    self.ticketNameLabel.text = [CommonMethod paramStringIsNull:model.name];
    if(model.remainnum.integerValue==-1){
        self.ticketNumLabel.text = @"名额不限";
    }else{
        self.ticketNumLabel.text = [NSString stringWithFormat:@"剩余:%@",[CommonMethod paramNumberIsNull:model.remainnum]];
    }
    if(model.price.floatValue){
        self.ticketTypeLabel.text = [NSString stringWithFormat:@"￥%@元/人", [CommonMethod paramNumberIsNull:model.price]];
    }else{
        self.ticketTypeLabel.text = @"免费";
    }
    if([CommonMethod paramStringIsNull:model.remark].length){
        [self.ticketInfoLabel setParagraphText:model.remark lineSpace:8];
    }else{
        self.ticketInfoLabel.text = @"暂无简介";
    }
}

+ (CGFloat)getCellHeight:(TicketModel*)model{
    CGFloat height = [NSHelper heightOfString:model.remark font:FONT_SYSTEM_SIZE(14) width:WIDTH-56 defaultHeight:FONT_SYSTEM_SIZE(14).lineHeight];
    height += (NSInteger)(height/FONT_SYSTEM_SIZE(14).lineHeight-1)*8;
    return height+90;
}

@end
