//
//  MyActivityOrderCell.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/6/13.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "MyActivityOrderCell.h"

@interface MyActivityOrderCell ()

@property (weak, nonatomic) IBOutlet UIImageView *activityImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *ticketNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UIButton *firstBtn;
@property (weak, nonatomic) IBOutlet UIButton *secondBtn;

@property (nonatomic, strong) ActivityOrderModel *model;

@end

@implementation MyActivityOrderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.stateLabel.layer.cornerRadius = 2;
    self.stateLabel.layer.borderWidth = 0.3;
    self.stateLabel.layer.masksToBounds = YES;
    // Initialization code
}

- (void)updateDisplay:(ActivityOrderModel *)model{
    self.model = model;
    [self.activityImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KWidthImageDefault];
    self.nameLabel.text = model.name;
    self.timeLabel.text = model.timestr;
    self.addressLabel.text = [NSString stringWithFormat:@"%@%@", [CommonMethod paramStringIsNull:model.cityname], [CommonMethod paramStringIsNull:model.districtname]];
    self.ticketNameLabel.text = model.ticketname;
    self.stateLabel.text = model.stat;
    self.priceNumLabel.text = [NSString stringWithFormat:@"¥%@ x %@张", model.price, model.ticketnum];
    self.amountLabel.text = [NSString stringWithFormat:@"¥%@元", model.amount];
    if(model.status.integerValue == 0){//待支付
        self.stateLabel.layer.borderColor = HEX_COLOR(@"e24943").CGColor;
        self.stateLabel.textColor = HEX_COLOR(@"e24943");
        self.firstBtn.hidden = NO;
        [self.firstBtn setTitle:@"取消订单" forState:UIControlStateNormal];
        self.secondBtn.hidden = NO;
        [self.secondBtn setBackgroundImage:kImageWithName(@"btn_bg_red") forState:UIControlStateNormal];
        [self.secondBtn setTitle:@"立即支付" forState:UIControlStateNormal];
    }else if(model.status.integerValue == 1){//已付款
        self.stateLabel.layer.borderColor = HEX_COLOR(@"1abc9c").CGColor;
        self.stateLabel.textColor = HEX_COLOR(@"1abc9c");
        self.firstBtn.hidden = NO;
        if(model.amount.floatValue == 0){
            [self.firstBtn setTitle:@"取消报名" forState:UIControlStateNormal];
        }else{
            [self.firstBtn setTitle:@"申请退票" forState:UIControlStateNormal];
        }
        self.secondBtn.hidden = NO;
        [self.secondBtn setBackgroundImage:kImageWithName(@"btn_bg_green") forState:UIControlStateNormal];
        [self.secondBtn setTitle:@"查看详情" forState:UIControlStateNormal];
    }else if(model.status.integerValue == 2){//审核中
        self.stateLabel.layer.borderColor = HEX_COLOR(@"f76b1c").CGColor;
        self.stateLabel.textColor = HEX_COLOR(@"f76b1c");
        self.firstBtn.hidden = NO;
        if(model.amount.floatValue == 0){
            [self.firstBtn setTitle:@"取消报名" forState:UIControlStateNormal];
        }else{
            [self.firstBtn setTitle:@"申请退票" forState:UIControlStateNormal];
        }
        self.secondBtn.hidden = NO;
        [self.secondBtn setBackgroundImage:kImageWithName(@"btn_bg_green") forState:UIControlStateNormal];
        [self.secondBtn setTitle:@"查看详情" forState:UIControlStateNormal];
    }else if(model.status.integerValue == 3){//退款中
        self.stateLabel.layer.borderColor = HEX_COLOR(@"f76b1c").CGColor;
        self.stateLabel.textColor = HEX_COLOR(@"f76b1c");
        self.firstBtn.hidden = YES;
        self.secondBtn.hidden = NO;
        [self.secondBtn setBackgroundImage:kImageWithName(@"btn_bg_green") forState:UIControlStateNormal];
        [self.secondBtn setTitle:@"查看详情" forState:UIControlStateNormal];
    }else if(model.status.integerValue == 4){//已退款
        self.stateLabel.layer.borderColor = HEX_COLOR(@"afb6c1").CGColor;
        self.stateLabel.textColor = HEX_COLOR(@"afb6c1");
        self.firstBtn.hidden = YES;
        self.secondBtn.hidden = NO;
        [self.secondBtn setBackgroundImage:kImageWithName(@"btn_bg_green") forState:UIControlStateNormal];
        [self.secondBtn setTitle:@"查看详情" forState:UIControlStateNormal];
    }else if(model.status.integerValue == 5){//已取消
        self.stateLabel.layer.borderColor = HEX_COLOR(@"afb6c1").CGColor;
        self.stateLabel.textColor = HEX_COLOR(@"afb6c1");
        self.firstBtn.hidden = YES;
        self.secondBtn.hidden = YES;
    }else{//已结束
        self.stateLabel.layer.borderColor = HEX_COLOR(@"afb6c1").CGColor;
        self.stateLabel.textColor = HEX_COLOR(@"afb6c1");
        self.firstBtn.hidden = YES;
        self.secondBtn.hidden = NO;
        [self.secondBtn setBackgroundImage:kImageWithName(@"btn_bg_green") forState:UIControlStateNormal];
        [self.secondBtn setTitle:@"查看详情" forState:UIControlStateNormal];
    }
}

- (IBAction)buttonClicked:(UIButton*)sender{
    if (sender.tag == 200) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(myActivityOrderClickedFirstBtn:model:)]){
            [self.delegate myActivityOrderClickedFirstBtn:self model:self.model];
        }
    }else{
        if(self.delegate && [self.delegate respondsToSelector:@selector(myActivityOrderClickedSecondBtn:model:)]){
            [self.delegate myActivityOrderClickedSecondBtn:self model:self.model];
        }
    }
}

@end
