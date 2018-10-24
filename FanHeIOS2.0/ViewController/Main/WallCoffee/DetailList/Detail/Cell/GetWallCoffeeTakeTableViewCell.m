//
//  GetWallCoffeeTakeTableViewCell.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/11/17.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "GetWallCoffeeTakeTableViewCell.h"
#import "ShowQRCodeViewController.h"

@interface GetWallCoffeeTakeTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *QRImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateSubLabel;

@property (nonatomic, strong) MyGetCoffeeModel *model;
@property (nonatomic, assign) BOOL isMyGetCoff;

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

@end

@implementation GetWallCoffeeTakeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [CALayer updateControlLayer:self.headerImageView.layer radius:20 borderWidth:0 borderColor:nil];
    [CommonMethod viewAddGuestureRecognizer:self.headerImageView tapsNumber:1 withTarget:self withSEL:@selector(gotoHomePage)];
    [CommonMethod viewAddGuestureRecognizer:self tapsNumber:1 withTarget:self withSEL:@selector(gotoQRCode)];
}

- (void)gotoHomePage{
    NewMyHomePageController *vc = [[NewMyHomePageController alloc]  init];
    if(!self.isMyGetCoff){
        vc.userId = self.model.userid;
    }else{
        vc.userId = [DataModelInstance shareInstance].userModel.userId;
    }
    [[self viewController].navigationController pushViewController:vc animated:YES];
}

- (void)gotoQRCode{
    if(self.isMyGetCoff&&[CommonMethod paramStringIsNull:self.model.admintime].length==0){
        ShowQRCodeViewController *vc = [CommonMethod getVCFromNib:[ShowQRCodeViewController class]];
        vc.codeStr = self.model.code;
        vc.coffeeId = self.model.coffeeid;
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }
}

+ (CGFloat)getCellHeight:(MyGetCoffeeModel*)model isMyGetCodffee:(BOOL)isMyGetCodffee{
    NSString *contentStr = model.takemessage;
    CGFloat height = [NSHelper heightOfString:contentStr font:FONT_SYSTEM_SIZE(14) width:WIDTH-149 defaultHeight:15];
    if(isMyGetCodffee){
        return height+183;
    }else{
        return height+102;
    }
}

- (void)updateDisply:(MyGetCoffeeModel*)model isMyGetCodffee:(BOOL)isMyGetCodffee{
    self.isMyGetCoff = isMyGetCodffee;
    self.model = model;
    self.timeLabel.text = model.taketime;
    self.contentLabel.text = model.takemessage;
    
    if(isMyGetCodffee&&[CommonMethod paramStringIsNull:model.admintime].length==0){
        self.QRImageView.hidden = NO;
    }else{
        self.QRImageView.hidden = YES;
    }
    //我领取了咖啡
    if(isMyGetCodffee){
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:[DataModelInstance shareInstance].userModel.image] placeholderImage:KHeadImageDefaultName([DataModelInstance shareInstance].userModel.realname)];
        self.nameLabel.text = [NSString stringWithFormat:@"我领取了%@的“人脉咖啡”",model.realname];
    }else{
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
        self.nameLabel.text = [NSString stringWithFormat:@"%@领取了我的“人脉咖啡”",model.realname];
    }
    self.codeLabel.text = [NSString stringWithFormat:@"兑换编号：%@",model.code];
    if([CommonMethod paramStringIsNull:model.admintime].length){
        self.stateLabel.text = @"已兑换";
        self.stateLabel.textColor = HEX_COLOR(@"818c9e");
        self.stateSubLabel.text = [NSString stringWithFormat:@"兑换时间：%@",model.admintime];
    }else{
        self.stateLabel.text = @"未兑换";
        self.stateLabel.textColor = HEX_COLOR(@"E24943");
        self.stateSubLabel.text = @"*可凭二维码至前台领取";
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
